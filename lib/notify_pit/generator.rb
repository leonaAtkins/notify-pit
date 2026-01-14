module NotifyPit
  class Generator
    WORDS = %w[Dog Cat Fox Bear Lion Tiger Wolf Fish Bird Frog Owl Deer].freeze

    def self.username
      Array.new(6) { ('a'..'z').to_a.sample }.join
    end

    def self.password
      WORDS.sample(3).join
    end

    def self.body(username, password)
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
