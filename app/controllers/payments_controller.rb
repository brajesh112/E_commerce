class PaymentsController < ApplicationController
	
	def new
	end

	def create
  end
  
  def success
  	debugger
    redirect_to root_url, notice: "Purchase Successful"
  end
  
  def cancel
    #handle if the payment is cancelled
    redirect_to root_url, notice: "Purchase Unsuccessful"
  end

  def show
  	debugger
  	if params[:id].eql?("success")
  		current_user.orders.last.update(status: 'paid')
  		current_user.orders.last.payments.create(status: "success")
  		return redirect_to orders_path
  	else
  		current_user.orders.last.update(status: 'pending')
  		current_user.orders.last.payments.create(status: "failed")
  		return redirect_to new_order_path
  	end
  	byebug
  end
end