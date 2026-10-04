# E-Commerce

A Ruby on Rails e-commerce application: product catalog, cart/checkout, Stripe
payments (webhook-driven), seller payouts, order tracking/shipments, an
ActiveAdmin back office, and Firebase web push notifications.

## Stack

- **Ruby** 3.4.10 (see `.ruby-version`)
- **Rails** 8.0
- **PostgreSQL**
- **Sidekiq** (background jobs) + Redis
- **Devise** (auth), **CanCanCan** (authorization), **ActiveAdmin** (admin)
- **Stripe** (payments), **Twilio** (SMS), **Firebase Cloud Messaging** (web push)
- **Cloudinary** (image storage via ActiveStorage)
- **RSpec** + factory_bot (tests)

## Setup

```bash
# 1. Install the Ruby version and gems
rbenv install 3.4.10     # or your version manager of choice
bundle install

# 2. Configure secrets
cp .env.example .env     # then fill in real values (see below)

# 3. Create and migrate the database
bin/rails db:create db:migrate

# 4. Run
bin/rails server         # http://localhost:3000
bundle exec sidekiq      # background jobs (in another shell)
```

### Configuration

All secrets are read from environment variables (via `.env` in development).
Copy `.env.example` and fill in: database credentials, `APP_HOST`, Stripe keys
(including `STRIPE_WEBHOOK_SECRET`), Twilio, Google OAuth, Cloudinary, and the
Firebase web-push keys. `.env` is gitignored — never commit real values.

### Stripe webhook

Payment state is driven **only** by the Stripe webhook, never by the browser
redirect. Point Stripe at `POST /stripe/webhook` and set `STRIPE_WEBHOOK_SECRET`.
Locally:

```bash
stripe listen --forward-to localhost:3000/stripe/webhook
```

## Tests

```bash
bundle exec rspec
```

The suite uses a real test database (factories, no DB stubbing); only
third-party APIs (Stripe, Twilio, Firebase) are stubbed at the service boundary.

## Deployment

A `Dockerfile` is provided. Production requires `RAILS_MASTER_KEY` (or
`config/master.key`), `DATABASE_URL`, and the same service env vars. SSL is
forced in production (`config.force_ssl = true`).
