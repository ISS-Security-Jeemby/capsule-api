# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(capsule_id: :capsules, letter_id: { table: :letters, type: :uuid })
  end
end
