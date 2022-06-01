# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Find or create an SsoAccount based on Github code
  class AuthorizeGoogleSso
    def call(access_token)
      google_account = get_google_account(access_token)
      google_sso_account = find_or_create_google_sso_account(google_account)

      account_and_token(google_sso_account)
    end

    def get_google_account(access_token)
      # google_response = HTTP.headers(
      #   user_agent: 'TimeCapsule',
      #   authorization: "token #{access_token}",
      #   accept: 'application/json'
      # ).get(ENV.fetch('GOOGLE_ACCOUNT_URL'))
      google_response = HTTP.auth("Bearer #{access_token}"
                        ).get(ENV.fetch('GOOGLE_ACCOUNT_URL'))

      raise unless google_response.status == 200

      account = GoogleAccount.new(JSON.parse(google_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_google_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_sso_account(account_data)
    end

    # rubocop:disable Style/HashSyntax
    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
    # rubocop:enable Style/HashSyntax
  end
end
