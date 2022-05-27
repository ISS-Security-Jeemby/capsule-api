# frozen_string_literal: true

module TimeCapsule
  # Policy to determine if an account can view a particular capsule
  class CollaborationRequestPolicy
    def initialize(capsule, requestor_account, target_account)
      @capsule = capsule
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = CapsulePolicy.new(requestor_account, capsule)
      @target = CapsulePolicy.new(target_account, capsule)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @capsule.collaborators.include?(@target_account)
    end
  end
end
