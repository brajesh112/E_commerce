class PaymentsController < ApplicationController
	
	def new
	end

	def create
  end
  
  def success
    #handle successful payments
    debugger
    redirect_to root_url, notice: "Purchase Successful"
  end
  
  def cancel
    #handle if the payment is cancelled
    redirect_to root_url, notice: "Purchase Unsuccessful"
  end
end