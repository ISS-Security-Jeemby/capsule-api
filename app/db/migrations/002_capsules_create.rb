# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:capsules) do
      primary_key :id
      foreign_key :account_id, table: :accounts

      String :name, null: false

      DateTime :created_at
      DateTime :updated_at

      # 1: private, 2: public, 3: received
      Integer :type, null: false, default: 1
    end
  end
end
