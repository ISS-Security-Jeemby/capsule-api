# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Register and send verification email' do
    before do
      @token = { username: 'ruby',
        email: 'hanchien.yu@iss.nthu.edu.tw',
       }

       def mail_json # rubocop:disable Metrics/MethodLength
        {
          personalizations: [{
            to: [{ 'email' => @token[:email] }]
          }],
          from: { 'email' => 'jessica.huang+timecapsule@iss.nthu.edu.tw' },
          subject: 'Time Capsule Registration Verification',
          content: [
            { type: 'text/html',
              value: 'test' }
          ]
        }
      end
      WebMock.enable!
      WebMock.stub_request(:post, 'https://api.sendgrid.com/v3/mail/send')
             .to_return(body: mail_json.to_json,
                        status: 200,
                        headers: { 'content-type' => 'application/json' })
    end

    after do
      WebMock.disable!
    end

    it 'HAPPY: should send verification email' do

      post 'api/v1/auth/register',
           SignedRequest.new(app.config).sign(@token).to_json,
           @req_header

      _(last_response.status).must_equal 202
    end
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = TimeCapsule::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { username: @account_data['username'],
                      password: @account_data['password'] }
      post 'api/v1/auth/authenticate',
           SignedRequest.new(app.config).sign(credentials).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)
      account = auth_account['attributes']['account']
      _(last_response.status).must_equal 200
      _(account['username']).must_equal(@account_data['username'])
      _(account['email']).must_equal(@account_data['email'])
      # _(account['id']).must_be_nil
    end

    it 'BAD: should not authenticate invalid password' do
      bad_credentials = { username: @account_data['username'],
                          password: 'fakepassword' }

      post 'api/v1/auth/authenticate', SignedRequest.new(app.config)
                                                    .sign(bad_credentials).to_json, @req_header

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end

  describe 'GITHUB SSO Authorization' do
    before do
      WebMock.enable!
      WebMock.stub_request(:get, app.config.GITHUB_ACCOUNT_URL)
             .to_return(body: GH_ACCOUNT_RESPONSE[GOOD_GH_ACCESS_TOKEN],
                        status: 200,
                        headers: { 'content-type' => 'application/json' })
    end

    after do
      WebMock.disable!
    end

    it 'HAPPY AUTH SSO: should authenticate+authorize new valid GITHUB SSO account' do
      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }

      post 'api/v1/auth/sso',
           SignedRequest.new(app.config).sign(gh_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(GH_SSO_ACCOUNT['gh_sso_username'])
      _(account['email']).must_equal(GH_SSO_ACCOUNT['gh_email'])
      _(account['id']).must_be_nil
    end

    it 'HAPPY AUTH SSO: should authorize existing GITHUBSSO account' do
      wipe_database

      TimeCapsule::Account.create(
        username: GH_SSO_ACCOUNT['gh_sso_username'],
        email: GH_SSO_ACCOUNT['gh_email']
      )
      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }

      post 'api/v1/auth/sso',
           SignedRequest.new(app.config).sign(gh_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(GH_SSO_ACCOUNT['gh_sso_username'])
      _(account['email']).must_equal(GH_SSO_ACCOUNT['gh_email'])
      _(account['id']).must_be_nil
    end
  end

  describe 'Google SSO Authorization' do
    before do
      WebMock.enable!
      WebMock.stub_request(:get, app.config.GOOGLE_ACCOUNT_URL)
             .to_return(body: GOOGLE_ACCOUNT_RESPONSE[GOOD_GOOGLE_ACCESS_TOKEN],
                        status: 200,
                        headers: { 'content-type' => 'application/json' })
    end

    after do
      WebMock.disable!
    end

    it 'HAPPY AUTH GOOGLE SSO: should authenticate+authorize new valid GOOGLE SSO account' do
      google_access_token = { access_token: GOOD_GOOGLE_ACCESS_TOKEN }

      post 'api/v1/auth/google_sso',
           SignedRequest.new(app.config).sign(google_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(GH_SSO_ACCOUNT['gh_sso_username'])
      _(account['email']).must_equal(GH_SSO_ACCOUNT['gh_email'])
      _(account['id']).must_be_nil
    end

    it 'HAPPY AUTH GOOGLE SSO: should authorize existing GOOGLE SSO account' do
      wipe_database

      TimeCapsule::Account.create(
        username: GOOGLE_SSO_ACCOUNT['google_sso_username'],
        email: GOOGLE_SSO_ACCOUNT['google_email']
      )
      google_access_token = { access_token: GOOD_GOOGLE_ACCESS_TOKEN }

      post 'api/v1/auth/google_sso',
           SignedRequest.new(app.config).sign(google_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']

      _(last_response.status).must_equal 200
      _(account['username']).must_equal(GOOGLE_SSO_ACCOUNT['google_sso_username'])
      _(account['email']).must_equal(GOOGLE_SSO_ACCOUNT['google_email'])
      _(account['id']).must_be_nil
    end
  end
end
