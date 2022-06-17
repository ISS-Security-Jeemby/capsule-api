# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if account can view a letter
  class LetterPolicy
    # Scope of letter policies
    class AccountScope
      def initialize(auth, current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_letters(target_account, auth)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          []
        end
      end

      private

      def all_letters(account, auth)
        shared_capsule = account.owned_capsules.select { |owned_capsule| owned_capsule.type == 2 }.first
        letters = shared_capsule.collaborated_letters + shared_capsule.owned_letters
        letters.map do |letter|
          GetLetterQuery.call(
            requestor: auth, letter:
          )
        end
      end
    end
  end
end
