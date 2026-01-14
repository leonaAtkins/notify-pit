require 'spec_helper'

RSpec.describe 'NotifyPit' do
  # Helper for sending JSON
  def post_json(path, hash)
    post path, hash.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before(:each) do
    delete '/mocker/reset'
  end

  describe 'Standard Notify API' do
    it 'captures SMS and generates GovWifi body pattern' do
      post_json '/v2/notifications/sms', {
        phone_number: '07700900000',
        template_id: 'sms-temp'
      }

      expect(last_response.status).to eq(201)
      resp = JSON.parse(last_response.body)
      expect(resp['id']).not_to be_empty
      expect(resp['content']['body']).to include('Your GovWifi details are:')
      expect(resp['content']['body']).to match(/Username:\n[a-z]{6}/)
    end

    context 'when sending an account removal message' do
      it 'returns the specific account removed wording' do
        payload = {
          phone_number: '07123456789',
          template_id: 'user_account_removed_sms',
          personalisation: {}
        }

        post '/v2/notifications/sms', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expected_removal_text = 'Your GovWifi username and password has been removed.'
        resp = JSON.parse(last_response.body)
        puts("Response body: #{last_response.body}")
        expect(last_response.status).to eq(201)
        expect(resp['content']['body']).to include(expected_removal_text)
        # expect(resp['content']['body']).to include("text 'Go' to 07537 417 417")
      end
    end

    it 'captures Email and returns HTML content' do
      post_json '/v2/notifications/email', {
        email_address: 'test@example.com',
        template_id: 'email-temp'
      }

      expect(last_response.status).to eq(201)
      resp = JSON.parse(last_response.body)
      expect(resp['content']).to have_key('html')
    end

    it 'returns 404 for missing notifications' do
      get '/v2/notifications/invalid-id'
      expect(last_response.status).to eq(404)
    end

    it 'allows polling of received text messages' do
      post_json '/mocker/inbound-sms', { content: 'test 1', phone_number: '07700900001' }
      post_json '/mocker/inbound-sms', { content: 'test 2', phone_number: '07700900002' }
      get '/v2/received-text-messages'

      expect(last_response.status).to eq(200)
      msgs = JSON.parse(last_response.body)['received_text_messages']

      expect(msgs).not_to be_empty
      expect(msgs.first['content']).to eq('test 1')
      expect(msgs.length).to eq(2)
    end
  end

  describe 'Management API' do
    it 'resets the data stores' do
      post_json '/v2/notifications/sms', { phone_number: '07700', template_id: '1' }
      delete '/mocker/reset'

      get '/mocker/messages'
      expect(JSON.parse(last_response.body).length).to eq(0)
    end

    it 'provides a health check' do
      get '/health'
      expect(last_response.status).to eq(200)
    end
  end
end
