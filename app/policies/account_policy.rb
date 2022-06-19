# frozen_string_literal: true

# Policy to determine if account can view a capsule
class AccountPolicy
  def initialize(requestor, account)
    @requestor = requestor
    @account = account
  end

  def can_view?
    self_request?
  end

  private

  def self_request?
    @requestor == @account
  end
end
