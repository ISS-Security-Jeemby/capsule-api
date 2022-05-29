# frozen_string_literal: true

module TimeCapsule
  # Add a collaborator to another owner's existing capsule
  class CreateLetter
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more letters'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a letter with those attributes'
      end
    end

    def self.call(account:, capsule:, letter_data:)
      policy = Capsule.new(account, capsule)
      raise ForbiddenError unless policy.can_add_letters?

      add_letter(capsule, letter_data)
    end

    def self.add_letter(capsule, letter_data)
      capsule.add_letter(letter_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
