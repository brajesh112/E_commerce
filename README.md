# E-Commerce

A Ruby on Rails e-commerce application: product catalog, cart/checkout,
webhook-driven payments (Stripe cards + Razorpay UPI/cards), seller payouts,
order tracking/shipments, bulk product import, an ActiveAdmin back office, and
Firebase web push notifications.

## Stack

- **Ruby** 3.4.10 (see `.ruby-version`)
- **Rails** 8.0
- **PostgreSQL**
- **Sidekiq** (background jobs) + Redis
- **Devise** (auth), **CanCanCan** (authorization), **ActiveAdmin** 4 (admin, Tailwind v4)
- **Stripe** + **Razorpay** (payments), **Twilio** (SMS), **Firebase Cloud Messaging** (web push)
- **ActiveStorage**: Cloudinary (development), Amazon S3 (production)
- **roo** / **caxlsx** (Excel bulk-import template + import)
- **RSpec** + factory_bot (tests)

## Setup

```bash
# 1. Install the Ruby version and gems
rbenv install 3.4.10     # or your version manager of choice
bundle install

# 2. Configure secrets
cp .env.example .env     # then fill in real values (see below)

# 3. Create, migrate, and seed the database
bin/rails db:create db:migrate db:seed   # seeds are idempotent (re-runnable)

# 4. Build the ActiveAdmin stylesheet (Tailwind v4)
npm install
npm run build:css        # outputs app/assets/builds/active_admin.css

# 5. Run
bin/rails server         # http://localhost:3000
bundle exec sidekiq      # background jobs (in another shell)
```

Re-run `npm run build:css` after changing admin views or classes so the compiled
`app/assets/builds/active_admin.css` stays in sync.

### Configuration

All secrets are read from environment variables (via `.env` in development).
Copy `.env.example` and fill in: database credentials, `APP_HOST`, Stripe keys
(incl. `STRIPE_WEBHOOK_SECRET`), Razorpay keys (incl. `RAZORPAY_WEBHOOK_SECRET`),
Twilio, Google OAuth, Cloudinary, AWS S3 (`AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET`), and the Firebase web-push
keys. `.env` is gitignored — never commit real values.

### Payment webhooks

Payment state is driven **only** by the gateway webhook, never by the browser
redirect. Routing: cash is direct (no gateway), UPI uses Razorpay, and card
orders let the buyer choose Stripe or Razorpay.

- **Stripe** → `POST /stripe/webhook`, set `STRIPE_WEBHOOK_SECRET`.
  Local: `stripe listen --forward-to localhost:3000/stripe/webhook`
- **Razorpay** → `POST /razorpay/webhook`, set `RAZORPAY_WEBHOOK_SECRET`.
  Register events: `payment_link.paid`, `payment_link.expired`,
  `payment_link.cancelled`, `refund.processed`.

Refunds move an order to `refund_pending` and only become `refunded` once the
gateway confirms via webhook.

### File storage

ActiveStorage uses Cloudinary in development and Amazon S3 in production (set the
`AWS_*` vars above). Product images and the bulk-import file are stored here.

### Bulk product import

Admins and sellers can bulk-upload products from `/admin/products` → **Bulk
upload**. Download the `.xlsx` template (it includes reference sheets listing the
valid category / sub-category / variant codes), fill the Products sheet, and
upload. The file is saved and processed in a background job (Sidekiq must be
running); results — created count, per-row errors, and the stored file — appear
on the **Product Imports** page.

## Tests

```bash
bundle exec rspec
```

The suite uses a real test database (factories, no DB stubbing); only
third-party APIs (Stripe, Razorpay, Twilio, Firebase) are stubbed at the service
boundary.

## Deployment

A `Dockerfile` is provided. Production requires `RAILS_MASTER_KEY` (or
`config/master.key`), `DATABASE_URL`, the S3 `AWS_*` vars, and the same service
env vars. SSL is forced in production (`config.force_ssl = true`).

Precompile assets as part of the build (`bin/rails assets:precompile`). The
committed `app/assets/builds/active_admin.css` is served as-is; if you change the
admin UI, rebuild it with `npm run build:css` before deploying.
