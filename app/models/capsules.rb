# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module TimeCapsule
  STORE_DIR = 'app/db/store'

  # Holds a full secret Capsule
  class Capsule < Sequel::Model
    one_to_many :letters
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'capsule',
            attributes: {
              id:,
              name:,
              type:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
