require 'securerandom'
require 'time'

module NotifyPit
  class Store
    attr_reader :notifications, :messages

    def initialize
      @notifications = {} # Stores "Input" (The 'Go' triggers)
      @messages = []      # Stores "Output" (The replies to be polled)
    end

    # EFFECTIVE OUTBOX: Stores generated replies (Credentials)
    # This is what the test reads via /v2/received-text-messages
    def add_message(type, payload)
      id = SecureRandom.uuid

      # 1. Content Logic: Injection OR Auto-Generation
      if payload['content']
        message_content = payload['content']
      else
        user = payload.dig('personalisation', 'username') || Generator.username
        pass = payload.dig('personalisation', 'password') || Generator.password
        message_content = Generator.body(payload['template_id'], user, pass)
      end

      entry = {
        'id' => id,
        'type' => type,
        'user_number' => type == 'sms' ? payload['phone_number'] : payload['email_address'],
        'content' => message_content, # The test checks this field
        'template_id' => payload['template_id'],
        'personalisation' => payload['personalisation'],
        'status' => 'received', # Terminology matches "received" endpoint
        'created_at' => Time.now.utc.iso8601(6)
      }

      @messages << entry
      entry
    end

    # EFFECTIVE INBOX: Stores incoming requests (Triggers)
    # This is where the "Go" message lands
    def add_notification(payload)
      id = SecureRandom.uuid

      # 2. Body Generation (Standard Notify behavior)
      template_id = payload['template_id']
      user = payload.dig('personalisation', 'username') || Generator.username
      pass = payload.dig('personalisation', 'password') || Generator.password
      body_text = Generator.body(template_id, user, pass)

      entry = {
        'id' => id,
        'user_number' => payload['phone_number'] || payload['email_address'],
        'notify_number' => 'GovWifi',
        'body' => body_text,
        'template_id' => template_id,
        'personalisation' => payload['personalisation'],
        'created_at' => Time.now.utc.iso8601(6)
      }

      @notifications[id] = entry
      entry
    end

    def reset!
      @notifications = {}
      @messages = []
    end
  end
end
