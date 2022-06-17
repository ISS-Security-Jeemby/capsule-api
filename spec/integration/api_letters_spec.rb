# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Letter Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = TimeCapsule::Account.create(@account_data)
    @account.add_owned_capsule(DATA[:capsules][0])
    @capsule = @account.add_owned_capsule(DATA[:capsules][1])

    @wrong_account = TimeCapsule::Account.create(@wrong_account_data)
    @wrong_account.add_owned_capsule(DATA[:capsules][1])
    @wrong_letter_data = DATA[:letters][5]

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting Letters' do
    before do
      DATA[:letters].each do |letter|
        @capsule.add_owned_letter(letter)
      end
    end

    it 'HAPPY: should be able to get list of all letters' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/capsules/#{@capsule.id}/letters"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 6
    end

    it 'SAD: should return error if unauthorized account requested' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/capsules/#{@capsule.id}/letters"
      _(last_response.status).must_equal 403
    end

    it 'SAD: should return error if unknown capsule requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/capsules/foobar/letters'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Getting Single Letter' do
    before do
      @letter_data = DATA[:letters][1]
      @letter = @capsule.add_owned_letter(@letter_data)
    end

    it 'HAPPY: should be able to get details of a single letter' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/letters/#{@letter.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal @letter.id
      _(result['data']['attributes']['title']).must_equal @letter_data['title']
    end

    it 'SAD: should return error if unauthorized account requested' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/letters/#{@letter.id}"
      _(last_response.status).must_equal 403
    end

    it 'SAD: should return error if unknown letter requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/letters/foobar'

      _(last_response.status).must_equal 404
    end

    describe 'Getting Received Letter' do
      it 'HAPPY: should be able to get details of a single received letter' do
        letter_data = DATA[:letters][4]
        letter = @capsule.add_owned_letter(letter_data)

        header 'AUTHORIZATION', auth_header(@account_data)
        get "/api/v1/letters/#{letter.id}/received"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal letter.id
        _(result['data']['policies']['can_view']).must_equal true
      end

      it 'SAD: should return error if wrong requests' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get '/api/v1/letters/foobar/received'

        _(last_response.status).must_equal 404
      end

      it 'SAD: should return error if unauthorized account requests' do
        letter = @capsule.add_owned_letter(@wrong_letter_data)
        header 'AUTHORIZATION', auth_header(@account_data)
        get "/api/v1/letters/#{letter.id}/received"

        _(last_response.status).must_equal 403
      end
    end
  end

  describe 'Updating Letter' do
    before do
      @letter_data = DATA[:letters][1]
      @letter = @capsule.add_owned_letter(@letter_data)
    end

    it 'HAPPY: should be able to update details of a single letter' do
      new_letter_data = DATA[:letters][2]

      header 'AUTHORIZATION', auth_header(@account_data)
      put "/api/v1/letters/#{@letter.id}", new_letter_data.to_json
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['title']).must_equal new_letter_data['title']
      _(result['data']['status']).must_equal new_letter_data['status']
      _(result['data']['is_locked']).must_equal false
    end

    it 'SAD: should return error if unknown letter requested (update)' do
      header 'AUTHORIZATION', auth_header(@account_data)
      put '/api/v1/letters/foobar', @letter_data.to_json

      _(last_response.status).must_equal 400
    end
  end

  describe 'Deleting Letter' do
    it 'HAPPY: should be able to delete letter' do
      letter_data = DATA[:letters][1]
      deleted_letter = @capsule.add_owned_letter(letter_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "/api/v1/letters/#{deleted_letter.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['message']).must_equal 'Delete success'
    end

    it 'SAD: should return error if unknown letter requested (delete)' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete '/api/v1/letters/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Letters' do
    before do
      @capsule = TimeCapsule::Capsule.first
      @letter_data = DATA[:letters][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/capsules/#{@capsule.id}/letters", @letter_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      letter = TimeCapsule::Letter.first
      _(created['attributes']['id']).must_equal letter.id
      _(created['attributes']['title']).must_equal @letter_data['title']
      _(created['attributes']['content']).must_equal @letter_data['content']
    end

    it 'SAD: should return error when wrong letter data' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/capsules/foobar/letters', @letter_data.to_json
      _(last_response.status).must_equal 400
    end
  end

  # describe 'Getting Letters' do
  #   before do
  #     DATA[:letters].each do |letter|
  #       @capsule.add_owned_letter(letter)
  #     end
  #     # collaborator
  #     # DATA[:owners_letters]
  #     # DATA[:collaborators_letters]
  #     # @collaborator_data = DATA[:accounts][2]
  #     # @collaborator = TimeCapsule::Account.create(@collaborator_data)
  #     # @collaborator_shared_capsule = @account.add_owned_capsule(DATA[:capsules][1])
  #     # DATA[:letters].each do |letter|
  #     #   @collaborator_shared_capsule.add_owned_letter(letter)
  #     # end
  #   end

  #   describe 'Getting Received Letters' do
  #     it 'HAPPY: should be able to get received letters' do
  #       header 'AUTHORIZATION', auth_header(@account_data)
  #       get "api/v1/capsules/#{@capsule.id}/letters/received"
  #       _(last_response.status).must_equal 200
  #       binding.pry

  #       result = JSON.parse last_response.body
  #       # _(result['data']).must_equal 'Delete success'
  #     end

  #     # it 'SAD: should return error when unauthorized account request' do

  #     #   header 'AUTHORIZATION', auth_header(@account_data)
  #     #   post "api/v1/capsules/#{wrong_capsule_id}/letters", @letter_data.to_json
  #     #   _(last_response.status).must_equal 403
  #     # end
  #   end

  #   describe 'Getting Shared Letters' do
  #     it 'HAPPY: should be able to get shared letters' do
  #       header 'AUTHORIZATION', auth_header(@account_data)
  #       get "api/v1/capsules/#{@capsule.id}/letters/shared"
  #       _(last_response.status).must_equal 200

  #       result = JSON.parse last_response.body
  #       binding.pry
  #       _(result['data'].size).must_be :>, 0
  #     end

  #     it 'SAD: should return error when unauthorized account request' do
  #       header 'AUTHORIZATION', auth_header(@account_data)
  #       get "api/v1/capsules/#{@capsule.id}/letters/shared"
  #       _(last_response.status).must_equal 403
  #     end
  #   end
  # end
end
