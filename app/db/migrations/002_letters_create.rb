# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:letters) do
      primary_key :id
      foreign_key :capsule_id, table: :capsules

      String :title, null: false, default: ''
      String :content, null: false, default: ''
      String :receiver_id, null: false, default: ''


      DateTime :send_at
      DateTime :open_at
      DateTime :created_at

      # 1: draft, 2: ready to be send, 3: sent
      Integer :status, null: false, default: 1

      TrueClass :is_private, null: false, default: true
    end
  end
end
