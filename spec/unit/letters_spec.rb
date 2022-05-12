# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Letter Handling' do
  before do
    wipe_database

    DATA[:capsules].each do |capsule_data|
      TimeCapsule::Capsule.create(capsule_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    let_data = DATA[:letters][1]
    cap = TimeCapsule::Capsule.first
    new_let = cap.add_owned_letter(let_data)

    let = TimeCapsule::Letter.find(id: new_let.id)
    _(let.title).must_equal let_data['title']
    _(let.content).must_equal let_data['content']
    _(let.receiver_id).must_equal let_data['receiver_id']
    _(let.status).must_equal let_data['status']
    _(let.is_private).must_equal let_data['is_private']
  end

  it 'SECURITY: should not use deterministic integers' do
    let_data = DATA[:letters][1]
    cap = TimeCapsule::Capsule.first
    new_let = cap.add_owned_letter(let_data)

    _(new_let.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    let_data = DATA[:letters][1]
    cap = TimeCapsule::Capsule.first
    new_let = cap.add_owned_letter(let_data)
    stored_let = app.DB[:letters].first

    _(stored_let[:content_secure]).wont_equal new_let.content
  end
end
