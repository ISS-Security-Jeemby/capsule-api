# frozen_string_literal: true

require_relative '../policies/letter_policy'

module TimeCapsule
  # Add a collaborator to another owner's existing capsule
  class GetLetterQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that letter'
      end
    end

    # Error for cannot find a letter
    class NotFoundError < StandardError
      def message
        'We could not find that letter'
      end
    end

    # Letter for given requestor account
    def self.call(requestor:, letter:)
      raise NotFoundError unless letter

      policy = LetterPolicy.new(requestor[:account], letter, requestor[:scope])
      raise ForbiddenError unless policy.can_edit?

      letter
    end
  end
end
