# frozen_string_literal: true

module TimeCapsule
  # Find collaborators of an existing letter
  class GetAllCollaborators
    # Error for not allowed to get collaborators
    class ForbiddenError < StandardError
      def message = 'You are not allowed to get collaborators'
    end

    # rubocop:disable Metrics
    def self.call(letters:)
      # find letter and its shared capsule
      letter_array = []

      # when a letter passed in
      if letters.length == 1
        letter = TimeCapsule::Letter.first(id: letters['data']['attributes']['id'])
        shared_capsules = letter.shared_capsule

      # when letters passed in
      elsif letters.each do |letter_all|
        letter_result = TimeCapsule::Letter.first(id: letter_all['data']['attributes']['id'])
        shared_capsules = letter_result.shared_capsule
      end
        user_array = []
        shared_capsules.each do |shared_capsule|
          account = TimeCapsule::Account.first(id: shared_capsule.owner_id)
          user_array.push(account.username)
        end
        letter_array.push(user_array)
        letter_array
      end
    end
    # rubocop:enable Metrics
  end
end
