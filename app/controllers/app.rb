# frozen_string_literal: true

require 'json'
require 'roda'

module TimeCapsule
  # api for CapsulText
  class Api < Roda
    plugin :environments
    plugin :halt

    route do |routing|
      # set HTTP response header
      response['Content-Type'] = 'application/json'

      # handle Root Route
      routing.root do
        { message: 'CapsuleAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'capsules' do
          @caps_route = "#{@api_root}/capsules"

          routing.on String do |caps_id|
            routing.on 'letters' do
              @let_route = "#{@api_root}/capsules/#{caps_id}/letters"
              # GET api/v1/capsules/[caps_id]/letters/[let_id]
              routing.get String do |let_id|
                letter = Letter.where(capsule_id: caps_id, id: let_id).first
                letter ? letter.to_json : raise('Letter not found')
              rescue StandardError => e
                Api.logger.warn "LETTER NOT FOUND: CAPS_ID - #{caps_id} / LAT_ID - #{let_id}"
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/capsules/[caps_id]/letters
              routing.get do
                output = { data: Capsule.first(id: caps_id).letters }
                JSON.pretty_generate(output)
              rescue StandardError
                Api.logger.warn "LETTERS NOT FOUND: CAPS_ID - #{caps_id}"
                routing.halt 404, message: 'Could not find letters'
              end

              # POST api/v1/capsules/[ID]/letters
              routing.post do
                new_data = JSON.parse(routing.body.read)
                caps = Capsule.first(id: caps_id)
                new_caps = caps.add_letter(new_data)
                raise 'Could not save letter' unless new_caps

                response.status = 201
                response['Location'] = "#{@caps_route}/#{new_caps.id}"
                { message: 'Letter saved', data: new_caps }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError  => e
                Api.logger.error "UNKOWN ERROR: #{e.message}"
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/capsules/[ID]
            routing.get do
              caps = Capsule.first(id: caps_id)
              caps ? caps.to_json : raise('Capsule not found')
            rescue StandardError => e
              Api.logger.warn "CAPSULE NOT FOUND: #{caps_id}"
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/capsules
          routing.get do
            output = { data: Capsule.all }
            JSON.pretty_generate(output)
          rescue StandardError => e
            Api.logger.warn "ALL CAPSULES NOT FOUND: #{e.message}"
            routing.halt 404, { message: 'Could not find capsules' }.to_json
          end

          # POST api/v1/capsules
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_caps = Capsule.new(new_data)
            raise('Could not save capsule') unless new_caps.save

            response.status = 201
            response['Location'] = "#{@caps_route}/#{new_caps.id}"
            { message: 'Capsule saved', data: new_caps }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
  end
end
