class PaymentsController < ApplicationController
	
	def new
	end

	def create
  end
  
  # def success
  # 	debugger
  #   redirect_to root_url, notice: "Purchase Successful"
  # end
  
  # def cancel
  #   #handle if the payment is cancelled
  #   debugger
  #   redirect_to root_url, notice: "Purchase Unsuccessful"
  # end

  def show
  	@order = current_user.orders.last
  	@session = Stripe::Checkout::Session.retrieve(params[:session_id])
  	if params[:id].eql?("success")
  		@order.update(status: 'paid')
  		@order.payments.create(status: "success", payment_id: @session.payment_intent)
  		helpers.add_notification(@order, "Your Order Is Placed")
  		return redirect_to orders_path
  	else
  		@order.update(status: 'payment_failed')
  		@order.payments.create(status: "failed", payment_id: @session.payment_intent)
  		return redirect_to order_path(@order)
  	end
  end
end