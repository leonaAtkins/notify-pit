require 'sinatra/base'
require_relative 'notify_pit/generator'
require_relative 'notify_pit/store'

# << ADD THIS WRAPPER
module NotifyPit
  class App < Sinatra::Base
    configure do
      set :environment, :test
      disable :protection
      enable :logging
      # This ensures logs are flushed immediately to Docker logs
      $stdout.sync = true
    end

    before do
      # This will show up in your CodeBuild/Docker logs
      puts "--> #{request.request_method} #{request.path}"
      body_content = request.body&.read
      if body_content && !body_content.empty?
        puts "    Body: #{body_content}"
      end
        request.body&.rewind
    end

    # Use a class-level instance of the store
    DB = Store.new

    post '/v2/notifications/sms' do
      # Read the body once and parse it
      request_payload = JSON.parse(request.body.read)

      # Pass the hash directly to the store
      note = DB.add_notification('sms', request_payload)
      #note = DB.add_notification('sms', JSON.parse(request.body.read))
      json_res({
          id: note['id'],
          content: { body: note['body'], from_number: 'GovWifi' },
          template: { id: note['template_id'], version: 1 }
        }, 201)
    end

    post '/v2/notifications/email' do
      note = DB.add_notification('email', JSON.parse(request.body.read))
      json_res({
          id: note['id'],
          content: { body: note['body'], subject: 'GovWifi details',
                    html: "<p>#{note['body'].gsub("\n", '<br>')}</p>" },
          template: { id: note['template_id'], version: 1 }
        }, 201)
    end

    get '/v2/notifications/:id' do
      note = DB.notifications[params[:id]]
      note ? json_res(note) : status(404)
    end

    get '/v2/received-text-messages' do
      json_res({ 'received_text_messages' => DB.inbound_sms })
    end

    get '/mocker/messages' do
      json_res(DB.notifications.values)
    end

    delete '/mocker/reset' do
      DB.reset!
      status 204
      ''
    end

    # Management API (For Smoke Test Orchestration)
    post '/mocker/inbound-sms' do
      msg = DB.add_inbound_sms(JSON.parse(request.body.read))

      json_res(msg, 201)
    end

    get '/health' do
      status 200
      'OK'
    end
    private

    def json_res(data, code = 200)
      content_type :json
      status code
      data.to_json
    end
  end
end
