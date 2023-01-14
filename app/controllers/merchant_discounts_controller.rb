class MerchantDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @discounts = @merchant.bulk_discounts
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.new
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.new(create_params)
    bulk_discount.save
    redirect_to merchant_bulk_discounts_path(merchant.id)
  end

  def destroy
    destroy_discount = BulkDiscount.find(params[:id])
    destroy_discount.delete
    redirect_to(merchant_bulk_discounts_path(params[:merchant_id]))
    
  end

  private

  def create_params
    params.permit(:percent_off, :threshold, :merchant_id)
  end

end