# frozen_string_literal: true

module TimeCapsule
    # Create new configuration for a capsule
    class DeleteLetter
      # find the letter and update the letter
      def self.call( letter_id:)
        letter = Letter.first(id: letter_id).delete

        # letter.update(letter_data)
      end
    end
  end