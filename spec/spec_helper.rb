# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:letters].delete
  app.DB[:capsules].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:letters] = YAML.safe_load File.read('app/db/seeds/letter_seeds.yml')
DATA[:capsules] = YAML.safe_load File.read('app/db/seeds/capsule_seeds.yml')