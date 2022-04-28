# frozen_string_literal: true

module TimeCapsule
  # Service object to create a new capsule for an owner
  class CreateCapsuleForOwner
    def self.call(owner_id:, capsule_data:)
      Account.find(id: owner_id)
             .add_capsule(capsule_data)
    end
  end
end
