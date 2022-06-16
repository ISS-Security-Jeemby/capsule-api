# frozen_string_literal: true

module TimeCapsule
  # Find collaborators of an existing letter
  class GetLetterSenders
    # Error for not allowed to get collaborators
    class ForbiddenError < StandardError
      def message = 'You are not allowed to get collaborators'
    end

    def self.call(letter:)
      senders = []
      owner_capsule = Capsule.first(id: letter.capsule_id)
      # find owner_id and collaborators
      owner = Account.first(id: owner_capsule.owner_id)
      senders.push(owner.username)
      letter.shared_capsule.each do |collaborator_capsule|
        collaborator = Account.first(id: collaborator_capsule.owner_id)
        senders.push(collaborator.username)
      end
      senders
    end
  end
end
