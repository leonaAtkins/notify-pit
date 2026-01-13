source 'https://rubygems.org'

gem 'json'
gem 'puma'
gem 'sinatra'
gem 'rackup' # Required for Sinatra 3.0+ / Ruby 3.0+
gem 'puma'   # Production-grade server for Docker

group :test, :development do
  gem 'faraday' # For testing the running service
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
