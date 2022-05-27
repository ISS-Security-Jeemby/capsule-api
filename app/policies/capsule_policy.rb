# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular capsule
  class CapsulePolicy
    def initialize(account, capsule, letter = nil)
      @account = account
      @capsule = capsule
      @letter = letter
    end

    def can_view?
      account_is_owner? || account_is_collaborator?
    end

    def can_edit?
      account_is_owner? || account_is_collaborator?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_letters?
      account_is_owner? || account_is_collaborator?
    end

    def can_remove_letters?
      account_is_owner? || account_is_collaborator?
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? or account_is_collaborator?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_letters: can_add_letters?,
        can_delete_letters: can_remove_letters?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def account_is_owner?
      @capsule.owner == @account
    end

    def account_is_collaborator?
      @capsule.collaborated_letters.include?(@letter)
    end
  end
end
