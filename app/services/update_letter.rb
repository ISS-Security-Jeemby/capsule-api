# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class UpdateLetter
    # find the letter and update the letter
    def self.call(letter_data:, letter_id:)
      letter = Letter.first(id: letter_id)
      letter.update(letter_data)
    end
  end
end
