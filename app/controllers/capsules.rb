# frozen_string_literal: true

require 'roda'
require_relative './app'

module TimeCapsule
  # api for CapsulText
  class Api < Roda
    route('capsules') do |routing|
      routing.on String do |caps_id|
        routing.on 'letters' do
          @let_route = "#{@api_root}/capsules/#{caps_id}/letters"
          # GET api/v1/capsules/[caps_id]/letters/[let_id]
          routing.get String do |let_id|
            @req_letter = Letter.first(id: let_id)
            letter = GetLetterQuery.call(
              requestor: @auth_account, letter: @req_letter
            )
            letter ? letter.to_json : raise('Letter not found')
          rescue StandardError => e
            Api.logger.warn "LETTER NOT FOUND: CAPS_ID - #{caps_id} / LAT_ID - #{let_id}"
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/capsules/[caps_id]/letters
          routing.get do
            caps = GetCapsuleQuery.get_capsule(
              account: @auth_account, capsule: Capsule.first(id: caps_id)
            )
            letters = { data: caps.owned_letters }
            JSON.pretty_generate(letters)
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

          # routing.on('letters') do
          # POST api/v1/capsules/[ID]/letters
          routing.post do
            new_letter = CreateLetterForOwner.call(
              # account: @auth_account,
              capsule_id: caps_id,
              letter_data: JSON.parse(routing.body.read)
            )
            response.status = 201
            response['Location'] = "#{@letter_route}/#{new_letter.id}"
            { message: 'Letter saved', data: new_letter }.to_json
          rescue CreateLetter::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateLetter::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts e.full_message
            Api.logger.warn "Could not create letter: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
        # end

        # GET api/v1/capsules/[ID]
        routing.get do
          req_caps = Capsule.first(id: caps_id)
          # caps = GetCapsuleQuery.call(
          #   account: @auth_account, capsule: req_caps
          # )
          { data: req_caps }.to_json
        rescue GetCapsuleQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCapsuleQuery::NotFoundError => e
          puts e.full_message
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
        account = Account.first(username: @auth_account)
        capsules = account.capsules
        JSON.pretty_generate(data: capsules)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any capsules' }.to_json
      end
    end
  end
end
