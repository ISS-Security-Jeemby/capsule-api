# frozen_string_literal: true

require_relative './app'

module TimeCapsule
  # Web controller for Credence API
  class Api < Roda
    route('letters') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @letter_route = "#{@api_root}/letters"

      # GET api/v1/letters/[letter_id]
      routing.on String do |letter_id|
        @req_letter = Letter.first(id: letter_id)

        routing.get do
          letter = GetLetterQuery.call(
            requestor: @auth_account, letter: @req_letter
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
      end
    end
  end
end
