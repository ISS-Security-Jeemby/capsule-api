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

    def self.call(account:, capsule:)
      raise NotFoundError unless capsule

      policy = CapsulePolicy.new(account, capsule)
      raise ForbiddenError unless policy.can_view?

      capsule.full_details.merge(policies: policy.summary)
    end

    def self.get_capsule(account:, capsule:)
      raise NotFoundError unless capsule

      policy = CapsulePolicy.new(account, capsule)
      raise ForbiddenError unless policy.can_view?

      capsule
    end
  end
end