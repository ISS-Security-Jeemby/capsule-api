# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:capsule) do
      primary_key :id

      String :name, unique: true, null: false

      DateTime :created_at
      DateTime :updated_at

      # 1: private, 2: public, 3: received
      Integer :type, null: false, default: 1
    end
  end
end
