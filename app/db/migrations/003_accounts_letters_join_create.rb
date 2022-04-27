# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(collaborator_id: :accounts, letter_id: :letters)
  end
end