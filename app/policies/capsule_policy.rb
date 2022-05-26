# frozen_string_literal: true

# Policy to determine if account can view a letter
class CapsulePolicy
  def initialize(account, capsule)
    @account = account
    @capsule = capsule
  end

  def can_view?
    account_owns_letter? || account_collaborates_on_letter?
  end

  def can_edit?
    account_owns_letter? || account_collaborates_on_letter?
  end

  def can_delete?
    account_owns_letter? || account_collaborates_on_letter?
  end

  private

  def account_owns_letter?
    @capsule.letter.owner == @account
  end

  def account_collaborates_on_letter?
    @capsule.letter.collaborators.include?(@account)
  end
end
