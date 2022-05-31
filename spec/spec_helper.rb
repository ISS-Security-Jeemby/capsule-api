# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  TimeCapsule::Letter.map(&:destroy)
  TimeCapsule::Capsule.map(&:destroy)
  TimeCapsule::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = TimeCapsule::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  letters: YAML.load(File.read('app/db/seeds/letters_seed.yml')),
  capsules: YAML.load(File.read('app/db/seeds/capsules_seed.yml')),
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml'))
}.freeze
