
class InvoicesController < ApplicationController
  def index
    @invoices = Invoice.all
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @invoice = Invoice.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    @invoice = Invoice.find(params[:invoice_id])
    @invoice.invoice_items.update(invoice_params)
    redirect_to "/merchants/#{@merchant.id}/invoices/#{@invoice.id}"
    flash[:notice] = "Item Updated Successfully"
  end

  private
  def invoice_params
    params.permit(:status)
  end
end