# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module TimeCapsule
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_capsules, class: :'TimeCapsule::Capsule', key: :owner_id

    plugin :association_dependencies,
           owned_capsules: :destroy

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    def capsules
      owned_capsules
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = TimeCapsule::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          username:,
          email:
        }, options
      )
    end
  end
end
