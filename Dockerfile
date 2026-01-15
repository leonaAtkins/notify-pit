FROM ruby:4.0.0-alpine

# Install build dependencies for gems like Puma
# We include 'libc-dev' and 'gcompat' because Ruby 4.0 on Alpine
# sometimes needs these for native extensions.
RUN apk add --update --no-cache build-base curl libc-dev gcompat

WORKDIR /usr/src/app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the application code
COPY . .

# Expose the Sinatra port
EXPOSE 4567

# Start the server using rackup and the config.ru file
# --host 0.0.0.0 is mandatory for the container to be reachable
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "4567", "config.ru"]