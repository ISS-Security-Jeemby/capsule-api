# frozen_string_literal: true

module TimeCapsule
  # Add a collaborator to another owner's existing letter
  class AddCollaboratorToLetter
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of letter'
    end

    def self.call(collaborator_name:, letter_data:)
      collaborator = TimeCapsule::Account.first(username: collaborator_name)
      collaborator_capsule = TimeCapsule::Capsule.first(owner_id: collaborator.id, type: 2)
      # pass in the collaborator_capsule and the account
      collaborator_capsule.add_collaborated_letter(letter_data)
    end
  end
end
