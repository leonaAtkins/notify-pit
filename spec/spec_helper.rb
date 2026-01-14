require 'simplecov'
require 'simplecov-console'

# 1. Start SimpleCov BEFORE requiring any application code
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
])

SimpleCov.start do
  add_filter '/spec/'
  # Ensure it tracks files in the lib directory
  track_files 'lib/**/*.rb'
end

# 2. Set the environment to test
ENV['RACK_ENV'] = 'test'

# 3. Now require your application code
require_relative '../lib/notify_pit'

require 'rspec'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    # This must match your main Sinatra class name
    NotifyPit::App
  end
end