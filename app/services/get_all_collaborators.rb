# frozen_string_literal: true

module TimeCapsule
  # Find collaborators of an existing letter
  class GetAllCollaborators
    # Error for not allowed to get collaborators
    class ForbiddenError < StandardError
      def message = 'You are not allowed to get collaborators'
    end

    def self.call(letters:)
      # find letter and its shared capsule
      letter_array = []
      letters.each do |letter|
        letter_result = TimeCapsule::Letter.first(id: letter['data']['attributes']['id'])
        shared_capsules = letter_result.shared_capsule
        user_array = []
        shared_capsules.each do |shared_capsule|
          account = TimeCapsule::Account.first(id: shared_capsule.owner_id)
          user_array.push(account.username)
        end
        letter_array.push(user_array)
      end

      letter_array
    end
  end
end
