# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToProject service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TimeCapsule::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = TimeCapsule::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      TimeCapsule::AuthenticateAccount.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise TimeCapsule::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      TimeCapsule::AuthenticateAccount.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise TimeCapsule::AuthenticateAccount::UnauthorizedError
  end
end
