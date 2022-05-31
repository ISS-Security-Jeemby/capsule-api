# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Capsule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = TimeCapsule::Account.create(@account_data)
    @wrong_account = TimeCapsule::Account.create(@wrong_account_data)

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
        get 'api/v1/capsules'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single Capsule' do
      capsule = @account.add_owned_capsule(DATA[:capsules][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/capsules/#{capsule.id}"
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal capsule.id
      _(result['attributes']['name']).must_equal capsule.name
    end

    it 'SAD: should return error if unknown Capsule requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/capsules/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get capsule with wrong authorization' do
      capsule = @account.add_owned_capsule(DATA[:capsules][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/capsules/#{capsule.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_capsule(DATA[:capsules][0])
      @account.add_owned_capsule(DATA[:capsules][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/capsules/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Capsules' do
    before do
      @capsule_data = DATA[:capsules][0]
    end
  end
end
