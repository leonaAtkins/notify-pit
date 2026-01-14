module NotifyPit
  class Generator
    WORDS = %w[Dog Cat Fox Bear Lion Tiger Wolf Fish Bird Frog Owl Deer].freeze
    ACCOUNT_REMOVED_TEMPLATE_ID = "user_account_removed_sms"

    def self.username
      Array.new(6) { ('a'..'z').to_a.sample }.join
    end

    def self.password
      WORDS.sample(3).join
    end

    def self.body(template_id, username, password)
      puts ("Generator body called with template_id: #{template_id}")
      if template_id == ACCOUNT_REMOVED_TEMPLATE_ID
        <<~HTML
          Your GovWifi username and password has been removed. You won't be able to connect to GovWifi with your old credentials

          To reconnect, text 'Go' to 07537 417 417
        HTML
      else
        # Default to the credentials message
        <<~HTML
          Your GovWifi details are:
          Username:
          #{username}
          Password:
          #{password}
          Your password is case-sensitive with no spaces between words.

          Go to your wifi settings, select 'GovWifi' and enter your details.
        HTML
      end
    end
  end
end
