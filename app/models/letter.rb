# frozen_string_literal: true

require 'json'
require 'sequel'

module TimeCapsule
  # Holds a full secret letter
  class Letter < Sequel::Model
    many_to_one :capsule

    many_to_many :collaborators,
                 class: :'Credence::Account',
                 join_table: :accounts_letters,
                 left_key: :letter_id, right_key: :collaborator_id
    plugin :uuid, field: :id
    plugin :timestamps, collaborators: :nullify
    plugin :whitelist_security
    set_allowed_columns :title, :content, :status, :receiver_id, :is_private

    # Secure getters and setters
    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'letter',
            attributes: {
              id: id,
              title: title,
              content: content,
              receiver_id: receiver_id,
              status: status,
              is_private: is_private
            }
          },
          included: {
            capsule: capsule
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
