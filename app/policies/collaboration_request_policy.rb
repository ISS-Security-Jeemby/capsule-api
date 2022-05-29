# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular capsule
  class CollaborationRequestPolicy
    def initialize(letter, requestor_account, target_account)
      @letter = letter
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = LetterPolicy.new(requestor_account, letter)
      @target = LetterPolicy.new(target_account, letter)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @letter.collaborators.include?(@target_account)
    end
  end
end
