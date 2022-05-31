# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class CreateLetterForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more documents'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a document with those attributes'
      end
    end

    # find the capsule and store the letter in the specific capsule
    def self.call(capsule_id:, letter_data:)
      Capsule.first(id: capsule_id)
             .add_owned_letter(letter_data)
    end
  end
end
