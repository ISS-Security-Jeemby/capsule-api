# frozen_string_literal: true

require 'roda'
require_relative './app'

module TimeCapsule
  # api for CapsulText
  class Api < Roda # rubocop:disable Metrics/ClassLength
    route('capsules') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      routing.on String do |caps_id|
        routing.on 'letters' do
          @let_route = "#{@api_root}/capsules/#{caps_id}/letters"
          routing.is 'received' do
            # GET api/v1/capsules/[caps_id]/letters/received
            routing.get do
              # rubocop: disable Style/MethodCallWithoutArgsParentheses
              received_letters = Letter.where(receiver_id: @auth_account[:username])
                                       .where { status > 1 }
                                       .where { send_at < DateTime.now() }
              # rubocop: enable Style/MethodCallWithoutArgsParentheses
              letters = Array.new { TimeCapsule::Letter.new }

              senders = []
              received_letters.all.each do |letter|
                policy_letter = GetReceivedLetterQuery.call(requestor: @auth, letter:)
                letters.push(policy_letter)
                # get senders
                senders_array = GetLetterSenders.call(letter:)
                senders.push(senders_array)
              end
              letters = { data: letters, senders: }
              JSON.pretty_generate(letters)
            rescue GetCapsuleQuery::ForbiddenError => e
              puts e.full_message
              routing.halt 403, { message: e.message }.to_json
            rescue GetCapsuleQuery::NotFoundError => e
              puts e.full_message
              routing.halt 404, { message: e.message }.to_json
            rescue StandardError => e
              puts e.full_message
              puts "FIND CAPSULE ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end

          routing.is 'shared' do
            # GET api/v1/capsules/[caps_id]/letters/shared
            routing.get do
              letters = LetterPolicy::AccountScope.new(@auth, @auth_account).viewable
              JSON.pretty_generate(data: letters)
            rescue GetCapsuleQuery::ForbiddenError => e
              puts e.full_message
              routing.halt 403, { message: e.message }.to_json
            rescue GetCapsuleQuery::NotFoundError => e
              puts e.full_message
              routing.halt 404, { message: e.message }.to_json
            rescue StandardError => e
              puts "FIND CAPSULE ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end

          # GET api/v1/capsules/[caps_id]/letters
          routing.get do
            caps = Capsule.first(id: caps_id)
            letters = Array.new { TimeCapsule::Letter.new }
            caps.owned_letters.each do |letter|
              policy_letter = GetLetterQuery.call(
                requestor: @auth, letter:
              )
              letters.push(policy_letter)
            end

            letters = { data: letters }
            JSON.pretty_generate(letters)
          rescue GetLetterQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetLetterQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError
            routing.halt 404, { message: 'Could not find any projects' }.to_json
          end

          # POST api/v1/capsules/[ID]/letters
          routing.post do
            new_letter = CreateLetterForOwner.call(
              capsule_id: caps_id,
              letter_data: JSON.parse(routing.body.read)
            )
            response.status = 201
            response['Location'] = "#{@letter_route}/#{new_letter.id}"
            { message: 'Letter saved', data: new_letter }.to_json
          rescue CreateLetterForOwner::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts e.full_message
            Api.logger.warn "Could not create letter: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/capsules/[ID]
        routing.get do
          req_caps = Capsule.first(id: caps_id)
          caps = GetCapsuleQuery.call(
            auth: @auth, capsule: req_caps
          )
          raise GetCapsuleQuery::NotFoundError unless req_caps

          { data: caps }.to_json
        rescue GetCapsuleQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCapsuleQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND PROJECT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # POST api/v1/capsules/[account_id]
        routing.post do
          account_id = caps_id
          capsules = YAML.safe_load File.read('app/db/seeds/capsules_seed.yml')
          new_caps = Array.new { TimeCapsule::Capsule.new }
          capsules.each do |capsule_data|
            # add each capsule
            new_cap = Capsule.new(capsule_data)
            raise('Could not save capsule') unless new_cap.save

            new_caps.push(new_cap)

            # assign capsules to owner
            CreateCapsuleForOwner.call(
              owner_id: account_id, capsule_data: new_cap
            )
          end
          response.status = 201
          response['Location'] = @caps_route.to_s
          { message: 'Capsules created for owner', data: new_caps }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end

      # GET api/v1/capsules/
      routing.get do
        account = Account.first(username: @auth_account[:username])
        capsules = account.capsules
        JSON.pretty_generate(data: capsules)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any capsules' }.to_json
      end
    end
  end
end
