# frozen_string_literal: true

module TimeCapsule
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(google_account)
      @google_account = google_account
    end

    def username
      "#{@google_account['login']}@gmail"
      # @gh_account['login'] + '@github'
    end

    def email
      @google_account['email']
    end
  end
end
