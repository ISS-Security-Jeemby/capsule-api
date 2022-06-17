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
  owners_letters: YAML.load(File.read('app/db/seeds/letters_owner.yml')),
  collaborators_letters: YAML.load(File.read('app/db/seeds/letters_collaborators.yml'))
}.freeze
