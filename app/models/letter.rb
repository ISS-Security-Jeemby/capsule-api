# frozen_string_literal: true

require 'json'
require 'sequel'

module TimeCapsule
  # Holds a full secret letter
  class Letter < Sequel::Model
    # private_capsule
    many_to_one :capsule, class: :'TimeCapsule::Capsule'

    many_to_many :shared_capsule,
                 class: :'TimeCapsule::Capsule',
                 join_table: :capsules_letters,
                 left_key: :letter_id, right_key: :capsule_id

    plugin :association_dependencies, shared_capsule: :nullify

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :title, :content, :status, :receiver_id, :is_private, :is_locked

    # Secure getters and setters
    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'letter',
        attributes: {
          id:,
          title:,
          content:,
          receiver_id:,
          status:,
          is_private:,
          is_locked:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          capsule:,
          shared_capsule:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
