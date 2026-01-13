# ... SimpleCov setup ...
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'notify_pit' # This will now pull in the other files via require_relative
require 'bundler/setup'
require 'rack/test'
require 'rspec'
require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  # Minimum coverage requirement
  minimum_coverage 85
  # Filter out the spec files themselves from the report
  add_filter '/spec/'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

# Force RACK_ENV before loading Sinatra
ENV['RACK_ENV'] = 'test'

# Add lib to the load path so 'require notify_pit' works
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'notify_pit'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # This is critical: It tells Rack::Test exactly which class to run
  def app
    NotifyPit::App
  end
end