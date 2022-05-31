# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular capsule
  class CapsulePolicy
    def initialize(account, capsule, auth_scope = nil)
      @account = account
      @capsule = capsule
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && account_is_owner?
    end

    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_add_letters?
      can_write? && account_is_owner?
    end

    def can_remove_letters?
      can_write? && account_is_owner?
    end

    def can_add_collaborators?
      can_write? && account_is_owner?
    end

    def can_remove_collaborators?
      can_write? && account_is_owner?
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

    def can_read?
      @auth_scope ? @auth_scope.can_read?('capsules') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('capsules') : false
    end

    def account_is_owner?
      @capsule.owner == @account
    end
  end
end
