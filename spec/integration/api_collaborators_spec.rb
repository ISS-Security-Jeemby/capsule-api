# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Collaborator Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][2]

    @account = TimeCapsule::Account.create(@account_data)
    @another_account = TimeCapsule::Account.create(@another_account_data)
    @wrong_account = TimeCapsule::Account.create(@wrong_account_data)

    @shared_capsule_data = DATA[:capsules][1]
    @capsule = TimeCapsule::Capsule.create(@shared_capsule_data)

    @another_account_capsule = @another_account.add_owned_capsule(@shared_capsule_data)

    @letter_data = DATA[:letters][3]
    @letter = @capsule.add_owned_letter(@letter_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding collaborators to a letter' do
    it 'HAPPY: should add collaborator' do
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/letters/#{@letter.id}/collaborators", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 200
      _(added['email']).must_equal @another_account.email
    end

    it 'SAD AUTHORIZATION: should not add collaborator without authorization' do
      req_data = { email: @another_account.email }

      post "api/v1/letters/#{@letter.id}/collaborators", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'SAD: should not add an invalid collaborator' do
      req_data = { email: 'foobar' }

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/letters/#{@letter.id}/collaborators", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 200
      _(added).must_equal 'Collaborator not found'
    end

    it 'SAD: should not add an existing collaborator' do
      @collaborator = @another_account_capsule.add_collaborated_letter(@letter)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/letters/#{@letter.id}/collaborators", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 200
      _(added).must_equal 'Already a collaborator'
    end

    it 'SAD: should not add receiver as a collaborator' do
      @letter_data = DATA[:letters][5]
      @letter = @capsule.add_owned_letter(@letter_data)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/letters/#{@letter.id}/collaborators", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 200
      _(added).must_equal 'Receiver can not be a collaborator'
    end
  end
end
