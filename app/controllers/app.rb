# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'roda'

require_relative '../models/capsules'
require_relative '../models/letters'

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

          routing.on 'text' do |caps_id|
            routing.on 'letters' do
              @let_route = "#{@api_root}/capsules/#{caps_id}/letters"
              
              # GET api/v1/capsules/[caps_id]/letters/[let_id]
              routing.get String do |let_id|
                letter = Letter.where(capsule_id: caps_id, id: let_id).first
                letter ? letter.to_json : raise('Letter not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end
              # ---------------------------- below doesn't update yet -------
              # POST api/v1/text
              routing.post do
                new_data = JSON.parse(routing.body.read)
                new_doc = Letter.new(new_data)
                if new_doc.save
                  response.status = 201
                  { message: 'Letter saved', id: new_doc.id }.to_json
                else
                  routing.halt 400, { message: 'Could not save letter' }.to_json
                end
              end

              # GET api/v1/text/[id]
              routing.get String do |id|
                Letter.find(id).to_json
              rescue StanardError
                # Halt stops route and returns status, msg immediately
                routing.halt 404, { message: 'Letter not found' }.to_json
              end

              # GET api/v1/text
              routing.get do
                output = { letter_ids: Letter.all }
                JSON.pretty_generate(output)
              end
            end
          end
        end
      end
    end
  end
end
