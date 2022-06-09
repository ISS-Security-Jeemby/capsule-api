# frozen_string_literal: true

module TimeCapsule
  # Find collaborators of an existing letter
  class GetLetterCollaborators
    # Error for not allowed to get collaborators
    class ForbiddenError < StandardError
      def message = 'You are not allowed to get collaborators'
    end

    def self.call(letter_id:)
      # find letter and its shared capsule
      letter_result = TimeCapsule::Letter.first(id: letter_id)
      shared_capsules = letter_result.shared_capsule
      user_array = []
      shared_capsules.each do |shared_capsule|
        account = TimeCapsule::Account.first(id: shared_capsule.owner_id)
        user_array.push(account.username)
      end
      user_array
    end
  end
end
