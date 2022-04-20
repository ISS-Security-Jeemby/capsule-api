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
    plugin :whitelist_security
    set_allowed_columns :title, :content, :status, :receiver_id, :is_private

    
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'letter',
            attributes: {
              id: id ,
              title:title,
              content:content,
              receiver_id:receiver_id,
              status:status,
              is_private: is_private
            }
          },
          included: {
            capsule:capsule
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
