# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Find or create an SsoAccount based on Github code
  class AuthorizeGoogleSso
    class InvalidRegistration < StandardError; end

    def call(access_token)
      @is_register = false
      google_account = get_google_account(access_token)
      google_sso_account = Account.first(username: google_account[:email], email: google_account[:email])
      @is_register = true unless google_sso_account
      google_sso_account ||= create_google_sso_account(google_account)
      account_and_token(google_sso_account)
    end

    def get_google_account(access_token)
      # google_response = HTTP.headers(
      #   user_agent: 'TimeCapsule',
      #   authorization: "token #{access_token}",
      #   accept: 'application/json'
      # ).get(ENV.fetch('GOOGLE_ACCOUNT_URL'))
      google_response = HTTP.auth("Bearer #{access_token}").get(ENV.fetch('GOOGLE_ACCOUNT_URL'))

      raise unless google_response.status == 200

      account_email = JSON.parse(google_response)['email']
      { username: account_email, email: account_email }
    end

    def create_google_sso_account(account_data)
      exist_account = Account.first(email: account_data[:email])
      raise(InvalidRegistration, 'Email already used') if exist_account
      Account.create_sso_account(account_data)
    end

    # rubocop:disable Style/HashSyntax
    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account),
          account_id: account.id,
          is_register: @is_register
        }
      }
    end
    # rubocop:enable Style/HashSyntax
  end
end
