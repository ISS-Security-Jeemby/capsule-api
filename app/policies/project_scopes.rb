# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if account can view a capsule
  class CapsulePolicy
    # Scope of capsule policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_capsules(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |proj|
            includes_collaborator?(proj, @current_account)
          end
        end
      end

      private

      def all_capsules(account)
        account.owned_capsules + account.collaborations
      end

      def includes_collaborator?(capsule, account)
        capsule.collaborators.include? account
      end
    end
  end
end
