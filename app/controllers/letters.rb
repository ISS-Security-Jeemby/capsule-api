# frozen_string_literal: true

require_relative './app'

module TimeCapsule
  # Web controller for Credence API
  class Api < Roda
    route('letters') do |routing| # rubocop:disable Metrics/BlockLength
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @letter_route = "#{@api_root}/letters"

      # GET api/v1/letters/collaborators
      routing.is 'collaborators' do
        routing.get do
          letters = JSON.parse(routing.body.read)
          collaborators = GetAllCollaborators.call(letters:)

          { data: collaborators }.to_json
        rescue GetAllCollaborators::ForbiddenError => e
          puts e.full_message
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError => e
          puts e.full_message
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      # POST api/v1/letters/notice
      routing.is 'notice' do
        routing.post do
          reg_data = JSON.parse(routing.body.read)

          NoticeCollaborator.new(reg_data).call

          response.status = 202
          { message: 'Notice email sent' }.to_json
        end
      end

      # GET api/v1/letters/[letter_id]
      routing.on String do |letter_id| # rubocop:disable Metrics/BlockLength
        @req_letter = Letter.first(id: letter_id)

        routing.on('collaborators') do
          # POST api/v1/letters/[letter_id]/collaborators
          routing.post do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaboratorToLetter.call(
              collaborator_email: req_data['email'],
              letter_data: @req_letter
            )

            collaborator = { data: collaborator }
            JSON.pretty_generate(collaborator)
          rescue AddCollaboratorToLetter::ForbiddenError => e
            puts e.full_message
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            puts e.full_message
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # GET api/v1/letters/[letter_id]/collaborators
          routing.get do
            collaborators = GetLetterCollaborators.call(letter_id:)

            { data: collaborators }.to_json
          rescue GetLetterCollaborators::ForbiddenError => e
            puts e.full_message
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            puts e.full_message
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/letters/[letter_id]/received
        routing.on('received') do
          letter = GetReceivedLetterQuery.call(
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

        # DELETE api/v1/letters/[letter_id]
        routing.delete do
          DeleteLetter.call(letter_id:)
        rescue StandardError => e
          puts e.full_message
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # GET api/v1/letters/[letter_id]
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
          puts e.full_message
          puts "GET LETTER ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/letters/[letter_id]
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
