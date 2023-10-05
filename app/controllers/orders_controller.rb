class OrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	before_action :authenticate_user
	require 'prawn'
	def new
		if params[:value].present?
			current_user.cart.line_items.create(quantity: 1, product_id: params[:id]) unless current_user.cart.line_items.where(product_id: params[:id]).present?
			 @items = current_user.cart.line_items.where(product_id: params[:id])
		else
			@items = params[:item_id].to_i.eql?(0) ? current_user.cart.line_items : LineItem.where(id: params[:item_id])
		end
		 return redirect_to carts_path unless @items.present?
		 @address = current_user.addresses
		 @track = "TRC#{rand 100000..999999}"
		 @status = "pending"
		 @order = current_user.orders.new
	end

	def create
		unless params[:id].present?
			@order = current_user.orders.new(order_params)
			@items = LineItem.where(id: params[:order][:item_id].split)
			i = 1 
			@order.description = ""
			@products = []
			@items.all.map { |item| @products << item.product }
			@order.products << @products
			return redirect_to new_order_path, alert: "something went wrong" unless @order.save
			@description = ""
			@items.each do |item|
				create_order_items(item, i)
				i +=1
			end
			@order.update(description: @description)
		else
			@order = Order.find_by(id: params[:id])
			@items = @order.order_items
		end
			unless @order.payment_method.eql?('cash')
				session = StripePayment.checkout_session(current_user, @items) 
				return redirect_to(session.url , :allow_other_host=> true, data: {turbo: false})
			end
			redirect_to order_path(@order)
	end

	def show
		@order = Order.find_by(id: params[:id])
		# respond_to do |format|
	 #    format.html
	 #    format.pdf do
	 #      pdf = Prawn::Document.new
	 #      pdf.text "this is a pdf"
	 #      send_data pdf.render_file "mypdf.pdf"
	 #    end
	 #  end

	end

	def index
		orders = current_user.orders.all
		redirect_to root_path, alert: "You have not ordered anything at" unless orders.present?
		# byebug
		@orders = orders.page params[:page]
	end

	def update
		@order = Order.find_by(id: params[:id])
		return redirect_to root_path unless @order.present?
		if @order.status.eql?("paid")
			@order.update(status: "refunded", track_id: nil)
			StripePayment.refund_payment(@order) 
		else
			@order.update(status: "cancel", track_id: nil)
		end
		helpers.add_notification(@order, "Your Order Is Canceled")
		@order.shipment.destroy
		redirect_to orders_path
	end

	def order_pdf 
		order = Order.find_by(id: params[:order_id])
    send_data generate_pdf(order),
              filename: "#{order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
 #    send_file("/home/user/Downloads/#{user.user_name}.pdf",
 #              filename: "#{user.id}.pdf",
 #              type: "application/pdf")
 
	end

	private

		def order_params
			params.require(:order).permit(:address_id, :payment_method, :track_id, :status)
		end

    def generate_pdf(order)
      Prawn::Document.new do
        # text order.id, align: :center
        text "Address: #{order.id}"
        text "Email: #{order.description}"
      end.render
    end
		def create_order_items(item ,i)
			@description += helpers.description_body(item, i,@order)
			item.product.order_items.create(order_id: @order.id, quantity: item.quantity)
			item.product.stock -= item.quantity
			item.product.update(stock: item.product.stock)
			item.destroy
		end 
end