# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GetLetterSenders service' do
  before do
    wipe_database

    @account1 = TimeCapsule::Account.create(DATA[:accounts][0])
    @account2 = TimeCapsule::Account.create(DATA[:accounts][1])

    @shared_capsule_data = DATA[:capsules][1]
    @account1_shared_capsule = @account1.add_owned_capsule(@shared_capsule_data)
    @account2_shared_capsule = @account2.add_owned_capsule(@shared_capsule_data)

    @letter1 = TimeCapsule::Letter.create(DATA[:letters][3])

    @account1_shared_capsule.add_owned_letter(@letter1)
    @account2_shared_capsule.add_collaborated_letter(@letter1)
  end

  it 'HAPPY: should get all collaborators of a letter' do
    collaborators = TimeCapsule::GetLetterSenders.call(letter: @letter1)

    _(collaborators.count).must_equal 2
    _(collaborators[0]).must_equal @account1.username
    _(collaborators[1]).must_equal @account2.username
  end
end
