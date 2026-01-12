FROM ruby:3.3.0-alpine

# Install build essentials for puma
RUN build_deps="build-base" \
    && apk add --update --no-cache $build_deps

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "notify_pit.rb", "-o", "0.0.0.0"]