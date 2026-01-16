$stdout.sync = true
$stderr.sync = true

require 'sinatra/base'
require_relative 'notify_pit/generator'
require_relative 'notify_pit/store'

# << ADD THIS WRAPPER
module NotifyPit
  class App < Sinatra::Base
    configure do
      set :bind, '0.0.0.0'
      set :port, 4567
      set :environment, :test
      disable :protection
      enable :logging
      # This ensures logs are flushed immediately to Docker logs
      $stdout.sync = true
      use Rack::CommonLogger, $stdout
    end

    before do
      # This will show up in your CodeBuild/Docker logs
      puts "--> #{request.request_method} #{request.path}"
      body_content = request.body&.read
      puts "    Body: #{body_content}" if body_content && !body_content.empty?
      request.body&.rewind
    end

    # Use a class-level instance of the store
    DB = Store.new

    post '/v2/notifications/sms' do
      # Read the body once and parse it
      request_payload = JSON.parse(request.body.read)

      # Pass the hash directly to the store
      note = DB.add_notification(request_payload)
      trigger_id = ENV['GO_TEMPLATE_ID'] || 'go_template_id' # Set this in docker-compose if needed

      if request_payload['template_id'] == trigger_id
        puts "✨ [NotifyPit] 'Go' Message Detected. Generating user cred message"
        DB.add_message('sms', request_payload)
      end
      json_res({
        id: note['id'],
        content: { body: note['body'], from_number: 'GovWifi' },
        template: { id: note['template_id'], version: 1 }
      }, 201)
    end

    post '/v2/notifications/email' do
      request_payload = JSON.parse(request.body.read)
      note = DB.add_notification(request_payload)
      json_res({
        id: note['id'],
        content: { body: note['body'], from_number: 'GovWifi' },
        template: { id: note['template_id'], version: 1 }
      }, 201)
    end

    get '/v2/notifications/:id' do
      note = DB.notifications[params[:id]]
      note ? json_res(note) : status(404)
    end

    get '/v2/received-text-messages' do
      json_res({ 'received_text_messages' => DB.messages })
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
      msg = DB.add_message('sms', JSON.parse(request.body.read))
      json_res(msg, 201)
    end

    get '/health' do
      puts '>>> HEALTH CHECK ACCESSED BY AGENT <<<'
      status 200
      'OK'
    end

    not_found do
      puts "[MOCK 404] No route matches: #{request.request_method} #{request.path}"
      json_res({ error: 'Route not found', path: request.path }, 404)
    end

    private

    def json_res(data, code = 200)
      content_type :json
      status code
      data.to_json
    end
  end
end
