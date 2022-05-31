# frozen_string_literal: true

require_relative '../policies/capsule_policy'

module TimeCapsule
  # Add a collaborator to another owner's existing capsule
  class GetCapsuleQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that capsule'
      end
    end

    # Error for cannot find a capsule
    class NotFoundError < StandardError
      def message
        'We could not find that capsule'
      end
    end

    def self.call(auth:, capsule:)
      raise NotFoundError unless capsule

      policy = CapsulePolicy.new(auth[:account], capsule, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      capsule
    end
  end
end
