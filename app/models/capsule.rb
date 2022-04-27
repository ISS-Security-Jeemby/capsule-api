# frozen_string_literal: true

require 'json'
require 'sequel'

module TimeCapsule
  # Holds a full secret Capsule
  class Capsule < Sequel::Model
    many_to_one :owner, class: :'Credence::Account'
    one_to_many :letters
    plugin :association_dependencies, letters: :destroy

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
