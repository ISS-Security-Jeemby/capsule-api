# frozen_string_literal: true

require 'http'

module TimeCapsule
  ## Send Notice Collaborator email
  class NoticeCollaborator
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(co_info)
      @co_info = co_info
    end

    def from_email = ENV.fetch('SENDGRID_FROM_EMAIL')
    def mail_api_key = ENV.fetch('SENDGRID_API_KEY')
    def mail_url = 'https://api.sendgrid.com/v3/mail/send'

    def call
      
      raise(InvalidRegistration, 'This Email did not registered') unless email_available?
      binding.pry
      send_email_verification
    end

    def email_available?
      !(Account.first(email: @co_info['email']).nil?)
    end

    def html_email
      <<~END_EMAIL
        <H1>TimeCapsule App Collaboration Received</H1>
        <p>Congratulation! You can collaborate with other now~</p>
      END_EMAIL
    end

    def mail_json # rubocop:disable Metrics/MethodLength
      {
        personalizations: [{
          to: [{ 'email' => @co_info['email'] }]
        }],
        from: { 'email' => from_email },
        subject: 'Time Capsule Registration Verification',
        content: [
          { type: 'text/html',
            value: html_email }
        ]
      }
    end

    def send_email_verification
      res = HTTP.auth("Bearer #{mail_api_key}")
                .post(mail_url, json: mail_json)
      raise EmailProviderError if res.status >= 300
    rescue StandardError
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
