# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module TimeCapsule
  STORE_DIR = 'app/db/store'

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
          }
        }, options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Capsule::STORE_DIR) unless Dir.exist? Capsule::STORE_DIR
    end

    # Stores letter in file store
    def save
      File.write("#{Capsule::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one letter
    def self.find(find_id)
      letter_file = File.read("#{Capsule::STORE_DIR}/#{find_id}.txt")
      Letter.new JSON.parse(letter_file)
    end

    # Query method to retrieve index of all letters
    def self.all
      Dir.glob("#{Capsule::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Capsule::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
