# frozen_string_literal: true

require 'json'
require 'sequel'

module TimeCapsule
  # Holds a full secret Capsule
  class Capsule < Sequel::Model
    many_to_one :owner, class: :'TimeCapsule::Account'

    one_to_many :owned_letters, class: :'TimeCapsule::Letter', key: :capsule_id
    many_to_many :collaborated_letters,
                 class: :'TimeCapsule::Letter',
                 join_table: :capsules_letters,
                 left_key: :capsule_id, right_key: :letter_id

    plugin :association_dependencies,
           owned_letters: :destroy,
           collaborated_letters: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :type

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'capsule',
            attributes: {
              id: id,
              name: name,
              type: type
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
