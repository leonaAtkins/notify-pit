require 'securerandom'
require 'time'

module NotifyPit
  class Store
    attr_reader :notifications, :inbound_sms

    def initialize
      @notifications = {}
      @inbound_sms = []
    end

    def add_notification(type, payload)
      id = SecureRandom.uuid

      # Extract data from JSON payload
      template_id = payload['template_id']
      personalisation = payload['personalisation'] || {}

      # Determine username/password
      user = personalisation['username'] || Generator.username
      pass = personalisation['password'] || Generator.password

      # Use the Generator logic
      message_body = Generator.body(template_id, user, pass)

      entry = {
        'id' => id,
        'type' => type,
        'to' => type == 'sms' ? payload['phone_number'] : payload['email_address'],
        'body' => message_body,
        'template_id' => template_id,
        'personalisation' => { 'username' => user, 'password' => pass },
        'status' => 'delivered',
        'created_at' => Time.now.utc.iso8601(6)
      }

      @notifications[id] = entry
      entry
    end

    # Restored method to fix the NoMethodError
    def add_inbound_sms(payload)
      entry = {
        'id' => SecureRandom.uuid,
        'user_number' => payload['user_number'],
        'notify_number' => payload['notify_number'],
        'content' => payload['content'],
        'created_at' => Time.now.utc.iso8601(6)
      }
      @inbound_sms << entry
      entry
    end

    def reset!
      @notifications = {}
      @inbound_sms = []
    end
  end
end