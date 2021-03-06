# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  TimeCapsule::Letter.map(&:destroy)
  TimeCapsule::Capsule.map(&:destroy)
  TimeCapsule::Account.map(&:destroy)
end

def authenticate(account_data)
  TimeCapsule::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)
  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: TimeCapsule::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  letters: YAML.load(File.read('app/db/seeds/letters_seed.yml')),
  capsules: YAML.load(File.read('app/db/seeds/capsules_seed.yml')),
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  owners_letters: YAML.load(File.read('app/db/seeds/letters_owner.yml'))
}.freeze

## Github SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
GH_SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/gh_sso_account.yml'))

## Google SSO fixtures
GOOGLE_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/google_token_response.yml')
)
GOOD_GOOGLE_ACCESS_TOKEN = GOOGLE_ACCOUNT_RESPONSE.keys.first
GOOGLE_SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/google_sso_account.yml'))
