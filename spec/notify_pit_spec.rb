require 'rspec'
require 'rack/test'
require_relative 'app/notify_pit'

RSpec.describe 'NotifyPit Harness' do
  include Rack::Test::Methods
  def app; Sinatra::Application; end

  before { delete '/mocker/reset' }

  it 'mocks email notifications' do
    post '/v2/notifications/email', {
      email_address: 'user@example.com',
      template_id: 'email-temp-1',
      personalisation: { link: 'http://login.gov' }
    }.to_json

    expect(last_response.status).to eq(201)

    get '/mocker/messages'
    messages = JSON.parse(last_response.body)
    expect(messages.first['to']).to eq('user@example.com')
    expect(messages.first['type']).to eq('email')
  end

  it 'mocks sms notifications' do
    post '/v2/notifications/sms', {
      phone_number: '07700900000',
      template_id: 'sms-temp-1'
    }.to_json

    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)['id']).not_to be_nil
  end

  it 'supports inbound SMS simulation' do
    post '/mocker/inbound-sms', { phone_number: '07700900000', content: 'WiFi' }.to_json

    get '/v2/received-text-messages'
    expect(JSON.parse(last_response.body)['received_text_messages'].length).to eq(1)
  end
end