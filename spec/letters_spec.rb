# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Letter Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:capsules].each do |capsule_data|
      TimeCapsule::Capsule.create(capsule_data)
    end
  end

  it 'HAPPY: should be able to get list of all letters' do
    capsule = TimeCapsule::Capsule.first
    DATA[:letters].each do |letter|
      capsule.add_letter(letter)
    end

    get "api/v1/capsules/#{capsule.id}/letters"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single letter' do
    letter_data = DATA[:letters][1]

    letter = capsule.add_letter(letter_data).save

    get "/api/v1/capsules/#{capsule.id}/letters/#{letter.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal letter.id
    _(result['data']['attributes']['title']).must_equal letter_data['title']
  end

  it 'SAD: should return error if unknown letter requested' do
    capsule = TimeCapsule::Capsule.first
    get "/api/v1/capsules/#{capsule.id}/letters/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new letters' do
    capsule = TimeCapsule::Capsule.first
    letter_data = DATA[:letters][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/capsules/#{capsule.id}/letters",
         capsule_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    letter = TimeCapsule::Letter.first

    _(created['id']).must_equal letter.id
    _(created['title']).must_equal letter_data['title']
    _(created['content']).must_equal letter_data['content']
  end
end