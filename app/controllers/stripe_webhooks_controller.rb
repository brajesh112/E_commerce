class StripeWebhooksController < ApplicationController
  # Stripe is the caller: signature is the authentication, so skip CSRF and login.
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false

  def create
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    secret     = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    # Replay protection: Stripe delivers at-least-once. Ignore anything we've
    # already processed.
    return head :ok if StripeEvent.exists?(event_id: event.id)

    case event.type
    when "checkout.session.completed", "checkout.session.async_payment_succeeded"
      handle_paid(event.data.object)
    when "checkout.session.expired", "checkout.session.async_payment_failed"
      handle_failed(event.data.object)
    when "charge.refunded"
      handle_refunded(event.data.object)
    end

    StripeEvent.create(event_id: event.id, event_type: event.type)
    head :ok
  end

  private

  # Source of truth for a captured payment. Idempotent.
  def handle_paid(session)
    return unless session.payment_status == "paid"

    order = Order.find_by(id: session.client_reference_id)
    return if order.nil? || order.status == "paid"

    payment = order.payments.find_or_initialize_by(stripe_session_id: session.id)
    payment.update(status: :success, payment_id: session.payment_intent,
                   amount: payment.amount || order.amount)
    order.update(status: "paid") # fires Order#create_transaction (idempotent payout)
    helpers.add_notification(order, "Your Order Is Placed")
  end

  # Expired or declined checkout session: record the failure and release the
  # stock reserved at order-create.
  def handle_failed(session)
    order = Order.find_by(id: session.client_reference_id)
    return if order.nil? || order.status == "paid" || order.status == "payment_failed"

    payment = order.payments.find_or_initialize_by(stripe_session_id: session.id)
    payment.update(status: :failed, amount: payment.amount || order.amount)
    order.update(status: "payment_failed")
    order.restock!
  end

  # Stripe-confirmed refund. Marks the ledger and ensures the order reflects it.
  def handle_refunded(charge)
    payment = Payment.find_by(payment_id: charge.payment_intent)
    return if payment.nil?

    payment.update(status: :refunded)
    payment.order.update(status: "refunded") unless payment.order.status == "refunded"
  end
end
