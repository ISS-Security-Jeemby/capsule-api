# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'roda'

require_relative '../models/document'

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
      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'text' do
            # POST api/v1/text
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Letter.new(new_data)
              if new_doc.save
                response.status = 201
                { message: 'Letter saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save document' }.to_json
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
              output = { document_ids: Letter.all }
              JSON.pretty_generate(output)
            end
          end
        end
      end
    end
  end
end
