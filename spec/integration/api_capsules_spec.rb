# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Capsule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting projects' do
    describe 'Getting list of capsules' do
      before do
        @account_data = DATA[:accounts][0]
        account = TimeCapsule::Account.create(@account_data)
        account.add_owned_capsule(DATA[:capsules][0])
        account.add_owned_capsule(DATA[:capsules][1])
        account.add_owned_capsule(DATA[:capsules][2])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = TimeCapsule::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )
        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
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
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['name']).must_equal existing_capsule['name']
    end

    it 'SAD: should return error if unknown Capsule requested' do
      get '/api/v1/capsules/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      TimeCapsule::Capsule.create(name: 'New Capsule')
      TimeCapsule::Capsule.create(name: 'Newer Capsule')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end
  describe 'Creating New Projects' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @existing_capsule = DATA[:capsules][1]
    end

    it 'HAPPY: should be able to create new Capsules' do
      post 'api/v1/capsules', @existing_capsule.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      capsule = TimeCapsule::Capsule.first

      _(created['id']).must_equal capsule.id
      _(created['name']).must_equal @existing_capsule['name']
      _(created['type']).must_equal @existing_capsule['type']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @existing_capsule.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/capsules', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
