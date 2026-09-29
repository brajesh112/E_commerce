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

    case event.type
    when "checkout.session.completed"
      handle_completed(event.data.object)
    when "checkout.session.expired"
      handle_expired(event.data.object)
    end

    head :ok
  end

  private

  # Source of truth for payment state. Idempotent: safe to receive twice.
  def handle_completed(session)
    return unless session.payment_status == "paid"

    order = Order.find_by(id: session.client_reference_id)
    return if order.nil?
    return if order.status == "paid" # already processed

    order.update(status: "paid")
    unless order.payments.exists?(payment_id: session.payment_intent)
      order.payments.create(status: "success", payment_id: session.payment_intent)
    end
    helpers.add_notification(order, "Your Order Is Placed")
  end

  def handle_expired(session)
    order = Order.find_by(id: session.client_reference_id)
    return if order.nil? || order.status == "paid"

    order.update(status: "payment_failed")
  end
end
