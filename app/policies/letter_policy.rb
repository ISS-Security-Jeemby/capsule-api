# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular letter
  class LetterPolicy
    def initialize(account, letter, auth_scope = nil)
      @account = account
      @letter = letter
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && account_is_receiver?
    end

    def can_edit?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_access?
      can_write? && !letter_is_locked?
    end

    def can_delete?
      (can_write? || can_read?) && account_is_owner?
    end

    def can_add_letters?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_remove_letters?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_add_collaborators?
      can_write? && account_is_owner?
    end

    def can_remove_collaborators?
      can_write? && account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? or account_is_collaborator?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_access: can_access?,
        can_delete: can_delete?,
        can_add_letters: can_add_letters?,
        can_delete_letters: can_remove_letters?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('letters') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('letters') : false
    end

    def account_is_owner?
      capsule = TimeCapsule::Capsule.first(id: @letter.capsule_id)
      owner = TimeCapsule::Account.first(id: capsule.owner_id)
      owner == @account
    end

    def account_is_collaborator?
      collaborator_shared_capsule = TimeCapsule::Capsule.first(owner_id: @account.id, type: 2)
      collaborator_shared_capsule.collaborated_letters.include?(@letter)
    end

    def account_is_receiver?
      @letter.receiver_id == @account.username
    end

    def letter_is_locked?
      @letter.is_locked
    end
  end
end
