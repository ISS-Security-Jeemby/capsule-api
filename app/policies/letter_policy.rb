# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular letter
  class LetterPolicy
    def initialize(account, letter)
      @account = account
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

    def can_add_documents?
      account_is_owner? || account_is_collaborator?
    end

    def can_remove_documents?
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

    private

    def account_is_owner?
      @letter.owner == @account
    end

    def account_is_collaborator?
      @letter.collaborators.include?(@account)
    end
  end
end
