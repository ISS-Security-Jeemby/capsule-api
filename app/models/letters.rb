# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module TimeCapsule
  # Holds a full secret letter
  class Letter < Sequel::Model
    many_to_one :capsule

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'letter',
            attributes: {
              id:,
              title:,
              content:,
              status:,
              is_private:
            }
          },
          included: {
            capsule:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
