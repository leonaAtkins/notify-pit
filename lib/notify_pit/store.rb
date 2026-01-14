require 'securerandom'
require 'time'

module NotifyPit
  class Store
    attr_reader :notifications, :inbound_sms

    def initialize
      @notifications = {}
      @inbound_sms = []
    end

    def reset!
      @notifications.clear
      @inbound_sms.clear
    end

    def add_notification(type, payload)
      id = SecureRandom.uuid
      p = payload['personalisation'] || {}
      user = p['username'] || Generator.username
      pass = p['password'] || Generator.password

      entry = build_entry(id, type, payload, user, pass)
      @notifications[id] = entry
      entry
    end

    def add_inbound_sms(payload)
      # Generates metadata that the smoke tests poll for, including a UUID id
      # and high-precision created_at to avoid timestamp collisions.
      msg = {
        'id' => SecureRandom.uuid,
        'content' => payload['content'],
        'user_number' => payload['phone_number'],
        'notify_number' => '60022',
        'service_id' => 'fa80e418-ff49-445c-a29b-92c04a181207',
        'created_at' => Time.now.utc.iso8601(6)
      }
      @inbound_sms << msg
      msg
    end

    private

    def build_entry(id, type, payload, user, pass)
      {
        'id' => id,
        'type' => type,
        'to' => type == 'sms' ? payload['phone_number'] : payload['email_address'],
        'body' => Generator.body(user, pass),
        'personalisation' => { 'username' => user, 'password' => pass },
        'status' => 'delivered',
        'created_at' => Time.now.utc.iso8601(6),
        'template_id' => payload['template_id']
      }
    end
  end
end
