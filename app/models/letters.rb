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
              id: id || new_id,
              title:title,
              content:content,
              status:status,
            }
          },
          included: {
            capsule:capsule
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