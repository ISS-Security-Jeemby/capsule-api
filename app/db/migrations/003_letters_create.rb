# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:letters) do
      uuid :id, primary_key: true
      foreign_key :capsule_id, table: :capsules

      String :title, null: false, default: ''
      String :content_secure, null: false, default: ''
      String :receiver_id, null: false, default: ''

      DateTime :send_at
      DateTime :open_at
      DateTime :created_at

      # 1: draft, 2: sended, 3: reciever recieved
      Integer :status, null: false, default: 1

      FalseClass :is_locked, null: true, default: false
      TrueClass :is_private, null: false, default: true
    end
  end
end
