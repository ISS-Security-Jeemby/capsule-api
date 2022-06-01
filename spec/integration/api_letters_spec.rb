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
    @account.add_owned_capsule(DATA[:capsules][1])
    TimeCapsule::Account.create(@wrong_account_data)

    # DATA[:capsules].each do |capsule_data|
    #   TimeCapsule::Capsule.create(capsule_data)
    # end

    header 'CONTENT_TYPE', 'application/json'
  end

  it 'HAPPY: should be able to get list of all letters' do
    capsule = TimeCapsule::Capsule.first
    DATA[:letters].each do |letter|
      capsule.add_owned_letter(letter)
    end

    header 'AUTHORIZATION', auth_header(@account_data)
    get "api/v1/capsules/#{capsule.id}/letters"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 6
  end

  it 'HAPPY: should be able to get details of a single letter' do
    letter_data = DATA[:letters][1]
    capsule = TimeCapsule::Capsule.first
    letter = capsule.add_owned_letter(letter_data)

    header 'AUTHORIZATION', auth_header(@account_data)
    get "/api/v1/capsules/#{capsule.id}/letters/#{letter.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal letter.id
    _(result['data']['attributes']['title']).must_equal letter_data['title']
  end

  it 'SAD: should return error if unknown letter requested' do
    capsule = TimeCapsule::Capsule.first
    header 'AUTHORIZATION', auth_header(@account_data)
    get "/api/v1/capsules/#{capsule.id}/letters/foobar"

    _(last_response.status).must_equal 404
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
      _(created['data']['attributes']['id']).must_equal letter.id
      _(created['data']['attributes']['title']).must_equal @letter_data['title']
      _(created['data']['attributes']['content']).must_equal @letter_data['content']
    end
  end
end
