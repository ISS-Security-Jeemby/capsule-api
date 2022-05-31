# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Capsule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @account = TimeCapsule::Account.create(@account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting capsules' do
    describe 'Getting list of capsules' do
      before do
        @account.add_owned_capsule(DATA[:capsules][0])
        @account.add_owned_capsule(DATA[:capsules][1])
        @account.add_owned_capsule(DATA[:capsules][2])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/capsules'
        _(last_response.status).must_equal 200
        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 3
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/projects'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
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

    # it 'SAD: should return error if unknown Capsule requested' do
    #   header 'AUTHORIZATION', auth_header(@account_data)
    #   get '/api/v1/capsules/foobar'

    #   _(last_response.status).must_equal 404
    # end

    # it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    #   TimeCapsule::Capsule.create(name: 'New Capsule')
    #   TimeCapsule::Capsule.create(name: 'Newer Capsule')
    #   get 'api/v1/projects/2%20or%20id%3E0'

    #   # deliberately not reporting error -- don't give attacker information
    #   _(last_response.status).must_equal 404
    #   _(last_response.body['data']).must_be_nil
    # end
  end
  describe 'Creating New Projects' do
    before do
      @capsule_data = DATA[:capsules][0]
    end

    # it 'HAPPY: should be able to create new Capsules for owner' do
    #   header 'AUTHORIZATION', auth_header(@account_data)
    #   post 'api/v1/capsules', @capsule_data.to_json
    #   binding.irb

    #   _(last_response.status).must_equal 201
    #   _(last_response.header['Location'].size).must_be :>, 0

    #   created_capsules = JSON.parse(last_response.body)['data'][0]['attributes']
    #   capsule = TimeCapsule::Capsule.first

    #   _(created_capsules['id']).must_equal capsule.id
    #   _(created_capsules['name']).must_equal capsule.name
    #   _(created_capsules['type']).must_equal capsule.type
    # end
  end
end
