class BankAccountsController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_user!, only: [:edit, :index]

	def new
		@value = params[:value].present? ? params[:value] : nil
		 return redirect_to root_path, alert:"Please Login" unless user_signed_in? || @value.present?
		@account = BankAccount.new 
	end

	def create
		return redirect_to seller_signups_path(permit_params) if params[:bank_account][:query].present?
		@account = current_user.bank_accounts.new(permit_params)
		@account.save
		helpers.add_notification(@account, "Bank Account Added To Your Profile")
		redirect_to bank_accounts_path
	end

	def edit
		@account = BankAccount.find_by(id: params[:id])
		return redirect_to root_path, alert: "Account not found" unless @account.present?
	end

	def update
		@account = BankAccount.find_by(id: params[:id])
		return redirect_to root_path, alert: "Account not found" unless @account.present?
		@account.update(permit_params)
		helpers.add_notification(@account, "Bank Account Updated On Your Profile")
		redirect_to bank_accounts_path
	end

	def index
		@accounts = current_user.bank_accounts.all
	end 

	def destroy 
		@account = BankAccount.find_by(id: params[:id])
		return redirect_to root_path, alert: "Account not found" unless @account.present?
		helpers.add_notification(@account, "Bank Account Removed from Your Profile")
		@account.destroy
		redirect_to bank_accounts_path
	end

	private
		def permit_params 
			params.require(:bank_account).permit(:account_no, :ifsc_code, :bank, :branch_name, :city, :user_id)
		end
end
