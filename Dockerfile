# syntax=docker/dockerfile:1
# Production image for the E-Commerce Rails app.
FROM ruby:3.4.10-slim AS base

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    RAILS_SERVE_STATIC_FILES=1 \
    RAILS_LOG_TO_STDOUT=1

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential libpq-dev postgresql-client nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install gems first so this layer caches across code changes.
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Precompile assets (dummy key: real RAILS_MASTER_KEY is injected at runtime).
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

EXPOSE 3000

# Run pending migrations, then boot Puma.
CMD ["bash", "-c", "bin/rails db:migrate && bundle exec puma -C config/puma.rb"]
