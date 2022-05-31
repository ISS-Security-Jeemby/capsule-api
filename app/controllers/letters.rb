# frozen_string_literal: true

require_relative './app'

module TimeCapsule
  # Web controller for Credence API
  class Api < Roda
    route('letters') do |routing| # rubocop:disable Metrics/BlockLength
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @letter_route = "#{@api_root}/letters"

      # GET api/v1/letters/[letter_id]
      routing.on String do |letter_id| # rubocop:disable Metrics/BlockLength
        @req_letter = Letter.first(id: letter_id)

        routing.on('collaborator') do
          # POST api/v1/letters/[letter_id]/collaborator
          routing.post do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaboratorToLetter.call(
              collaborator_email: req_data['email'],
              letter_data: @req_letter
            )

            { data: collaborator }.to_json
          rescue AddCollaboratorToLetter::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.get do
          letter = GetLetterQuery.call(
            requestor: @auth, letter: @req_letter
          )

          { data: letter }.to_json
        rescue GetLetterQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetLetterQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET LETTER ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.put do
          letter = JSON.parse(routing.body.read)
          UpdateLetter.call(letter_data: letter, letter_id:)

          { data: letter }.to_json
        rescue StandardError => e
          puts e.full_message
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end