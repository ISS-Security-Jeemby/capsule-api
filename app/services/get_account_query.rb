# frozen_string_literal: true

require_relative '../policies/account_policy'

module TimeCapsule
  # Add a collaborator to another owner's existing capsule
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that capsule'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username:)

      policy = AccountPolicy.new(requestor, username)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
