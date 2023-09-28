class PaymentsController < ApplicationController
  def new
  end
  
  def create
    customer = Stripe::Customer.create({
      :email => params[:stripeEmail],
      :source => params[:stripeToken]
    })
    
    Stripe::Checkout::Session.create({
		  success_url: 'https://example.com',
		  cancel_url: 'https://example.com',
		})
  
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_payment_path
  end
end