# frozen_string_literal: true

# Policy to determine if an account can view a particular letter
class LetterPolicy
  def initialize(account, letter)
    @account = account
    @letter = letter
  end

  def can_view?
    account_owns_capsule? || account_collaborates_on_capsule?
  end

  def can_edit?
    account_owns_capsule? || account_collaborates_on_capsule?
  end

  def can_delete?
    account_owns_capsule? || account_collaborates_on_capsule?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_capsule?
    @letter.capsule.owner == @account
  end

  def account_collaborates_on_capsule?
    @letter.capsule.collaborated_letters.include?(@letter)
  end
end
