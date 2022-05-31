# frozen_string_literal: true

# Policy to determine if an account can view a particular letter
class LetterPolicy
  def initialize(account, letter)
    @account = account
    @letter = letter
  end

  # duplication is ok!
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
    capsule = TimeCapsule::Capsule.first(id: @letter.capsule_id)
    owner = TimeCapsule::Account.first(id: capsule.owner_id)
    owner.username == @account
  end

  def account_is_collaborator?
    @letter.collaborators.include?(@account)
  end
end
