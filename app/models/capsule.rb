# frozen_string_literal: true

require 'json'
require 'sequel'

module TimeCapsule
  # Holds a full secret Capsule
  class Capsule < Sequel::Model
    many_to_one :owner, class: :'TimeCapsule::Account'

    one_to_many :owned_letters, class: :'TimeCapsule::Letter', key: :capsule_id, dependent: :destroy
    many_to_many :collaborated_letters,
                 class: :'TimeCapsule::Letter',
                 join_table: :capsules_letters,
                 left_key: :capsule_id, right_key: :letter_id

    plugin :association_dependencies,
           owned_letters: :destroy,
           collaborated_letters: :nullify

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :type

    def to_h
      {
        type: 'capsule',
        attributes: {
          id:,
          name:,
          type:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          collaborated_letters:,
          owned_letters:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
