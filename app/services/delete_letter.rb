# frozen_string_literal: true

module TimeCapsule
  # Create new configuration for a capsule
  class DeleteLetter
    class NotFoundLetter < StandardError; end

    # find the letter and update the letter
    def self.call(letter_id:)
      letter = Letter.first(id: letter_id)
      raise(NotFoundLetter) unless letter

      letter.delete
    end
  end
end
