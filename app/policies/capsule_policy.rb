# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular capsule
  class CapsulePolicy
    def initialize(account, capsule)
      @account = account
      @capsule = capsule
    end

    def can_view?
      account_is_owner?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_add_letters?
      account_is_owner?
    end

    def can_remove_letters?
      account_is_owner?
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      !account_is_owner?
    end

    def shared?
      @capsule.type == '2'
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_letters: can_add_letters?,
        can_delete_letters: can_remove_letters?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?,
        shared: shared?
      }
    end

    private

    def account_is_owner?
      @capsule.owner == @account
    end
  end
end
