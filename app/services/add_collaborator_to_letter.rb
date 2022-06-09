# frozen_string_literal: true

module TimeCapsule
  # Add a collaborator to another owner's existing letter
  class AddCollaboratorToLetter
    # Error for not allowed to add collaborators
    class ForbiddenError < StandardError
      def message = 'You are not allowed to add collaborators'
    end

    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of letter'
    end

    def self.call(collaborator_email:, letter_data:)
      # find account and its "shared capsule"
      collaborator = TimeCapsule::Account.first(email: collaborator_email)
      collaborator_capsule = TimeCapsule::Capsule.first(owner_id: collaborator.id, type: 2)

      # see if the new collaborator is already a collaborator
      if collaborator_capsule.collaborated_letters.select { |letter| letter.id == letter_data.id }.first
        return 'Already a collaborator'
      end

      owner_id = TimeCapsule::Capsule.first(id: letter_data.capsule_id).owner_id

      raise OwnerNotCollaboratorError if collaborator_capsule.owner_id == owner_id

      collaborator_capsule.add_collaborated_letter(letter_data)
      collaborator
    end
  end
end
