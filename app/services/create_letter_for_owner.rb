# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class CreateLetterForOwner
    # Error for requests with illegal capsule id
    class IllegalRequestError < StandardError
      def message
        'Cannot create a document with those attributes'
      end
    end

    # find the capsule and store the letter in the specific capsule
    def self.call(capsule_id:, letter_data:)
      capsule = Capsule.first(id: capsule_id)
      raise IllegalRequestError unless capsule

      capsule.add_owned_letter(letter_data)
    end
  end
end
