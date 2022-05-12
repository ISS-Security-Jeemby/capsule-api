# frozen_string_literal: true

module TimeCapsule
  # Add a collaborator to another owner's existing letter
  class AddCollaboratorToLetter
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of letter'
    end

    def self.call(collaborator_name:, letter_data:)
      # find account and its "shared capsule"
      collaborator = TimeCapsule::Account.first(username: collaborator_name)
      collaborator_capsule = TimeCapsule::Capsule.first(owner_id: collaborator.id, type: 2)

      owner_id = TimeCapsule::Capsule.first(id: letter_data.capsule_id).owner_id

      raise OwnerNotCollaboratorError if collaborator_capsule.owner_id == owner_id

      collaborator_capsule.add_collaborated_letter(letter_data)
    end
  end
end
