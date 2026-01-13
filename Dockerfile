FROM ruby:4.0.0-alpine

# Install build dependencies for gems like Puma and RuboCop
RUN apk add --update --no-cache build-base

WORKDIR /usr/src/app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the Sinatra port
EXPOSE 4567

# Default command starts the server
CMD ["bundle", "exec", "ruby", "-Ilib", "-rnotify_pit", "-e", "NotifyPit::App.run!(port: 4567, bind: '0.0.0.0')"]