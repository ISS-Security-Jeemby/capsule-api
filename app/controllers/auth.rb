# frozen_string_literal: true

require 'roda'
require_relative './app'

module TimeCapsule
  # Web controller for TimeCapsule API
  class Api < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          puts e.full_message
          routing.halt 400, { message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError => e
          puts e.full_message
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          puts e.full_message
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
      # POST /api/v1/auth/sso
      routing.post 'sso' do
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        auth_account = AuthorizeSso.new.call(auth_request[:access_token])
        { data: auth_account }.to_json
      rescue StandardError => e
        puts "FAILED to validate Github account: #{e.inspect}"
        puts e.backtrace
        routing.halt 400
      end
      # POST /api/v1/auth/google_sso
      routing.post 'google_sso' do
        auth_request = JsonRequestBody.parse_symbolize(request.body.read).to_json
        auth_request_token = JSON.parse(auth_request)['access_token']
        auth_account = AuthorizeGoogleSso.new.call(auth_request_token)
        { data: auth_account }.to_json
      rescue AuthorizeGoogleSso::InvalidRegistration => e
        puts e.full_message
        routing.halt 400, { message: e.message }.to_json
      rescue StandardError => e
        puts "FAILED to validate Google account: #{e.inspect}"
        puts e.backtrace
        routing.halt 400
      end
    end
  end
end
