# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class UpdateLetter
    class NotFoundLetter < StandardError; end

    # find the letter and update the letter
    def self.call(letter_data:, letter_id:)
      letter_data['is_locked'] = false if letter_data['is_locked'] == 'false'
      letter = Letter.first(id: letter_id)
      raise(NotFoundLetter) unless letter

      letter.update(letter_data)
    end
  end
end
