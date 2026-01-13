require 'securerandom'

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

      @notifications[id] = build_entry(id, type, payload, user, pass)
    end

    def add_inbound_sms(payload)
      msg = {
        'id' => SecureRandom.uuid,
        'content' => payload['content'],
        'user_number' => payload['phone_number'],
        'notify_number' => '60022',
        'created_at' => Time.now.iso8601
      }
      @inbound_sms << msg
      msg
    end

    private

    def build_entry(id, type, payload, user, pass)
      {
        'id' => id, 'type' => type,
        'to' => type == 'sms' ? payload['phone_number'] : payload['email_address'],
        'body' => Generator.body(user, pass),
        'personalisation' => { 'username' => user, 'password' => pass },
        'status' => 'delivered', 'created_at' => Time.now.iso8601,
        'template_id' => payload['template_id']
      }
    end
  end
end
