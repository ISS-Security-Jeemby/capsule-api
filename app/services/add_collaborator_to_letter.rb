# frozen_string_literal: true

module TimeCapsule
  # Add a collaborator to another owner's existing letter
  class AddCollaboratorToLetter
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of letter'
    end

    def self.call(email:, letter_id:)
      collaborator = Account.first(email:)
      letter = Letter.first(id: letter_id)
      raise(OwnerNotCollaboratorError) if letter.owner.id == collaborator.id

      letter.add_collaborator(collaborator)
    end
  end
end
