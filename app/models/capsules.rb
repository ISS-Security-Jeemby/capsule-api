# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module TimeCapsule
  # Holds a full secret Capsule
  class Capsule < Sequel::Model
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
              id: id || new_id,
              name: name,
              type: type
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
