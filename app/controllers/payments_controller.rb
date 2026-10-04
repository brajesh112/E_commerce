class PaymentsController < ApplicationController
  before_action :authenticate_user!

  # Post-checkout redirect target. DISPLAY ONLY — never mutates payment state.
  # The Stripe webhook (StripeWebhooksController) is the source of truth for
  # whether an order is paid; this action only shows the current status.
  def show
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @order  = current_user.orders.find_by(id: session.client_reference_id)
    return redirect_to orders_path, alert: "Order not found" if @order.nil?

    if params[:id].eql?("success")
      redirect_to orders_path, notice: order_status_message(@order)
    else
      redirect_to order_path(@order), alert: "Payment was cancelled."
    end
  rescue Stripe::StripeError
    redirect_to orders_path, alert: "Could not verify payment. Check your orders shortly."
  end

  # Razorpay redirects here after the hosted link. DISPLAY ONLY — the Razorpay
  # webhook is the source of truth; this only shows current status.
  def razorpay_return
    @order = current_user.orders.find_by(id: params[:razorpay_payment_link_reference_id])
    return redirect_to orders_path, alert: "Order not found" if @order.nil?

    if params[:razorpay_payment_link_status] == "paid"
      redirect_to orders_path, notice: order_status_message(@order)
    else
      redirect_to order_path(@order), alert: "Payment was not completed."
    end
  end

  private

  def order_status_message(order)
    order.status == "paid" ? "Your order is placed." : "Payment received — confirming your order…"
  end
end