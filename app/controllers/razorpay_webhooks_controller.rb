class RazorpayWebhooksController < ApplicationController
  # Razorpay is the caller: the HMAC signature is the authentication.
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false

  def create
    payload    = request.body.read
    sig_header = request.headers["X-Razorpay-Signature"]
    secret     = ENV["RAZORPAY_WEBHOOK_SECRET"]

    begin
      Razorpay::Utility.verify_webhook_signature(payload, sig_header, secret)
    rescue SecurityError
      return head :bad_request
    end

    event = JSON.parse(payload) rescue nil
    return head :bad_request if event.nil?

    case event["event"]
    when "payment_link.paid"
      handle_paid(event)
    when "payment_link.expired", "payment_link.cancelled"
      handle_failed(event)
    when "refund.processed", "refund.created"
      handle_refunded(event)
    end

    head :ok
  end

  private

  def link_entity(event)
    event.dig("payload", "payment_link", "entity") || {}
  end

  # Source of truth for a captured Razorpay payment. Idempotent via order status.
  def handle_paid(event)
    link = link_entity(event)
    order = Order.find_by(id: link["reference_id"])
    return if order.nil? || order.status == "paid"

    payment = order.payments.find_or_initialize_by(razorpay_payment_link_id: link["id"])
    payment.gateway = "razorpay"
    payment.update(status: :success,
                   payment_id: event.dig("payload", "payment", "entity", "id"),
                   amount: payment.amount || order.amount)
    order.update(status: "paid") # fires Order#create_transaction (idempotent payout)
    helpers.add_notification(order, "Your Order Is Placed")
  end

  # Expired or cancelled link: record the failure and release reserved stock.
  def handle_failed(event)
    link = link_entity(event)
    order = Order.find_by(id: link["reference_id"])
    return if order.nil? || order.status == "paid" || order.status == "payment_failed"

    payment = order.payments.find_or_initialize_by(razorpay_payment_link_id: link["id"])
    payment.gateway = "razorpay"
    payment.update(status: :failed, amount: payment.amount || order.amount)
    order.update(status: "payment_failed")
    order.restock!
  end

  # Razorpay-confirmed refund.
  def handle_refunded(event)
    refund = event.dig("payload", "refund", "entity") || {}
    payment = Payment.find_by(payment_id: refund["payment_id"], gateway: "razorpay")
    return if payment.nil?

    payment.update(status: :refunded)
    payment.order.update(status: "refunded") unless payment.order.status == "refunded"
  end
end
