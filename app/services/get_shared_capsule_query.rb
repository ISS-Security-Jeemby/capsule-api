# frozen_string_literal: true

require_relative '../policies/capsule_policy'

module TimeCapsule
  # Get letters in shared capsule
  class GetSharedCapsuleQuery
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

    def self.call(requestor:, letter:)
      raise NotFoundError unless letter

      policy = LetterPolicy.new(requestor[:account], letter, requestor[:scope])
      raise ForbiddenError unless policy.can_edit?

      letter.full_details.merge(policies: policy.summary)
    end
  end
end
