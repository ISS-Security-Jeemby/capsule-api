# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Capsule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all Capsules' do
    TimeCapsule::Capsule.create(DATA[:capsules][0]).save
    TimeCapsule::Capsule.create(DATA[:capsules][1]).save

    get 'api/v1/capsules'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single Capsule' do
    existing_capsule = DATA[:capsules][1]
    TimeCapsule::Capsule.create(existing_capsule).save
    id = TimeCapsule::Capsule.first.id

    get "/api/v1/capsules/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_capsule['name']
  end

  it 'SAD: should return error if unknown Capsule requested' do
    get '/api/v1/capsules/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new Capsules' do
    existing_capsule = DATA[:capsules][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/capsules', existing_capsule.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    capsule = TimeCapsule::Capsule.first

    _(created['id']).must_equal capsule.id
    _(created['name']).must_equal existing_capsule['name']
    _(created['type']).must_equal existing_capsule['type']
  end
end
