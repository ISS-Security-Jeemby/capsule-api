# frozen_string_literal: true

require 'http'

module TimeCapsule
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    class InvalidRegistration < StandardError; end

    def call(access_token)
      @is_register = false
      github_account = get_github_account(access_token)
      sso_account = Account.first(username: github_account[:email], email: github_account[:email])
      @is_register = true unless sso_account
      sso_account ||= create_sso_account(github_account)
      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'TimeCapsule',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV.fetch('GITHUB_ACCOUNT_URL'))
      raise unless gh_response.status == 200

      # 有人的github email private
      account_email = JSON.parse(gh_response)['email']
      { username: account_email, email: account_email }
    end

    def create_sso_account(account_data)
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
