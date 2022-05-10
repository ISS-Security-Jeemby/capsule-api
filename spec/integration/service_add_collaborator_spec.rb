# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToLetter service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TimeCapsule::Account.create(account_data)
    end

    letter_data = DATA[:letters].first

    @owner = TimeCapsule::Account.all[0]
    @collaborator = TimeCapsule::Account.all[1]

    # DATA[:capsules].each do |capsule_data|
    #   TimeCapsule::CreateCapsuleForOwner.call(
    #     owner_id: @owner.id, capssule_data: capsule_data # should be the corresponding capsule id
    #   )
    # end
    # @capsule = @owner.owned_capsules.first

    # need to find the owner's capsule first
    @letter = TimeCapsule::CreateLetterForOwner.call(
      capsule_id: @capsule.id, letter_data:
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
