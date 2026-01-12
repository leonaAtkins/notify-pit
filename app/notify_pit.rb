require 'sinatra'
require 'json'
require 'securerandom'

set :port, 4567

# In-memory stores categorized by type
DATA = {
  notifications: {}, # Keyed by ID
  inbound_sms: [],
  templates: {}      # Optional: storage for template metadata
}

helpers do
  def json_res(data, code = 200)
    content_type :json
    status code
    data.to_json
  end

  def capture_notification(type, payload)
    id = SecureRandom.uuid
    notification = {
      "id" => id,
      "type" => type,
      "to" => type == 'sms' ? payload['phone_number'] : payload['email_address'],
      "template_id" => payload['template_id'],
      "personalisation" => payload['personalisation'] || {},
      "status" => "delivered",
      "created_at" => Time.now.iso8601
    }
    DATA[:notifications][id] = notification
    notification
  end
end

# --- Notify Standard API Endpoints ---

# POST /v2/notifications/sms
post '/v2/notifications/sms' do
  payload = JSON.parse(request.body.read)
  note = capture_notification('sms', payload)
  json_res({ id: note["id"], content: { body: "Mock SMS Body" }, template: { id: note["template_id"] } }, 201)
end

# POST /v2/notifications/email
post '/v2/notifications/email' do
  payload = JSON.parse(request.body.read)
  note = capture_notification('email', payload)
  json_res({ id: note["id"], content: { body: "Mock Email Body", subject: "Mock Subject" }, template: { id: note["template_id"] } }, 201)
end

# GET /v2/notifications/:id
get '/v2/notifications/:id' do
  note = DATA[:notifications][params[:id]]
  note ? json_res(note) : status(404)
end

# GET /v2/received-text-messages
get '/v2/received-text-messages' do
  json_res({ "received_text_messages" => DATA[:inbound_sms] })
end

# --- Management/Harness APIs ---

# Simulate an inbound SMS from a user
post '/mocker/inbound-sms' do
  payload = JSON.parse(request.body.read)
  msg = {
    "id" => SecureRandom.uuid,
    "content" => payload['content'],
    "user_number" => payload['phone_number'],
    "notify_number" => "60022",
    "created_at" => Time.now.iso8601
  }
  DATA[:inbound_sms] << msg
  json_res(msg, 201)
end

# View all captured notifications (The "Mailpit" style dashboard data)
get '/mocker/messages' do
  json_res(DATA[:notifications].values)
end

delete '/mocker/reset' do
  DATA[:notifications].clear
  DATA[:inbound_sms].clear
  status 204
end