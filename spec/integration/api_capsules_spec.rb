# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Capsule Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account1_data = DATA[:accounts][0]
    @account2_data = DATA[:accounts][1]

    @account1 = TimeCapsule::Account.create(@account1_data)
    @account2 = TimeCapsule::Account.create(@account2_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting capsules' do
    describe 'Getting list of capsules' do
      before do
        @account1.add_owned_capsule(DATA[:capsules][0])
        @account1.add_owned_capsule(DATA[:capsules][1])
        @account1.add_owned_capsule(DATA[:capsules][2])
      end

      it 'HAPPY: should get all capsules for authorized account' do
        header 'AUTHORIZATION', auth_header(@account1_data)
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

      it 'BAD: should not process without authorization' do
        get 'api/v1/capsules'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single Capsule' do
      capsule = @account1.add_owned_capsule(DATA[:capsules][0])

      header 'AUTHORIZATION', auth_header(@account1_data)
      get "/api/v1/capsules/#{capsule.id}"
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal capsule.id
      _(result['attributes']['name']).must_equal capsule.name
    end

    it 'SAD: should return error if unknown Capsule requested' do
      header 'AUTHORIZATION', auth_header(@account1_data)
      get '/api/v1/capsules/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get capsule with wrong authorization' do
      capsule = @account1.add_owned_capsule(DATA[:capsules][0])

      header 'AUTHORIZATION', auth_header(@account2_data)
      get "/api/v1/capsules/#{capsule.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account1.add_owned_capsule(DATA[:capsules][0])
      @account1.add_owned_capsule(DATA[:capsules][1])

      header 'AUTHORIZATION', auth_header(@account1_data)
      get 'api/v1/capsules/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Capsules after creating an account' do
    it 'HAPPY: should be able to create 3 capsules' do
      header 'AUTHORIZATION', auth_header(@account1_data)
      post "/api/v1/capsules/#{@account1.id}"

      _(last_response.status).must_equal 201

      result = JSON.parse last_response.body
      _(result['message']).must_equal 'Capsules created for owner'
      _(result['data'].count).must_equal 3
    end
  end

  describe 'Getting letter in received capsule' do
    it 'HAPPY: should be able to get letters in received capsule' do
      @shared_capsule_data = DATA[:capsules][1]
      @account1_shared_capsule = @account1.add_owned_capsule(@shared_capsule_data)
      @account2_shared_capsule = @account2.add_owned_capsule(@shared_capsule_data)

      @received_letter = TimeCapsule::Letter.create(DATA[:letters][6])

      @account1_shared_capsule.add_owned_letter(@received_letter)

      header 'AUTHORIZATION', auth_header(@account2_data)
      get "/api/v1/capsules/#{@account2.id}/letters/received"

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 1
      _(result['data'][0]['attributes']['receiver_id']).must_equal @account2.username
      _(result['senders'].count).must_equal 1
      _(result['senders'][0][0]).must_equal @account1.username
    end
  end
end
