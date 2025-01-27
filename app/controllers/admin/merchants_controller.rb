class Admin::MerchantsController < ApplicationController
  def index
    @merchants = Merchant.all
    @merchants_enabled = Merchant.group_by_status("enabled")
    @merchants_disabled = Merchant.group_by_status("disabled")
    @merchants_top_five = Merchant.top_five
  end

  def new
    @merchant = Merchant.new
  end

  def create
    @merchant = Merchant.new(merchant_params)
    @merchant.status = "disabled"
    if @merchant.save 
      redirect_to admin_merchants_path
    else
      redirect_to new_admin_merchant_path
      flash[:alert] = "Error: #{@merchant.errors.full_messages}"
    end
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:id])
    if merchant_params[:status].present?
      @merchant.toggle_status
      redirect_to admin_merchants_path
    else
      @merchant.update(merchant_params)
      flash[:notice] = "Merchant successfully updated"
      redirect_to admin_merchant_path(@merchant)
    end
  end

  private
  def merchant_params
    params.require(:merchant).permit(:name, :status)
  end
end
