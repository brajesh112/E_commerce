class BankAccountsController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_user!
	def new
		@account = BankAccount.new
	end

	def create
		byebug
		@account = current_user.bank_accounts.new(permit_params)
		@account.save
		redirect_to bank_accounts_path
	end

	def edit
		@account = BankAccount.find_by(id: params[:id])
	end

	def update
		@account = BankAccount.find_by(id: params[:id])
		@account.update(permit_params)
		redirect_to bank_accounts_path
	end

	def index
		@accounts = BankAccount.all
	end 

	def destroy 
		@account = BankAccount.find_by(id: params[:id])
		@account.destroy
		redirect_to bank_accounts_path
	end

	def permit_params 
		params.require(:bank_account).permit(:account_no, :ifsc_code, :bank, :branch_name, :city, :user_id)
	end
end
