# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToLetter service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TimeCapsule::Account.create(account_data)
    end

    letter_data = TimeCapsule::Letter.first

    @owner = TimeCapsule::Account.all[0]
    @collaborator = TimeCapsule::Account.all[1]
    @letter = TimeCapsule::CreateLetterForOwner.call(
      owner_id: @owner.id, letter_data:
    )
  end

  it 'HAPPY: should be able to add a collaborator to a letter' do
    TimeCapsule::AddCollaboratorToLetter.call(
      email: @collaborator.email,
      letter: @letter
    )

    _(@collaborator.letters.count).must_equal 1
    _(@collaborator.letters.first).must_equal @letter
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      TimeCapsule::AddCollaboratorToLetter.call(
        collaborator_name: @owner.username,
        letter_data: @letter
      )
    }).must_raise TimeCapsule::AddCollaboratorToLetter::OwnerNotCollaboratorError
  end
end
