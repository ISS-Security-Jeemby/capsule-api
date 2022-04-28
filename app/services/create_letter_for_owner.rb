# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class CreateLetterForOwner
    def self.call(capsule_id:, letter_data:)
      Capsule.first(id: capsule_id)
             .add_owned_letter(letter_data)
    end
  end
end