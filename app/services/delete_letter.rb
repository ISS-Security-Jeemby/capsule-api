# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class DeleteLetter
    # find the letter and update the letter
    def self.call(letter_id:)
      Letter.first(id: letter_id).delete
    end
  end
end
