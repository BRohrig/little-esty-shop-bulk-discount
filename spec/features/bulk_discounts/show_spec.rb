require 'rails_helper'

RSpec.describe "bulk discount show page" do
  before(:all) do
    BulkDiscount.delete_all
    InvoiceItem.delete_all
    Transaction.delete_all
    Invoice.delete_all
    Item.delete_all
    Customer.delete_all
    Merchant.delete_all
    @merchant1 = create(:merchant, name: "Ye Olde Test Shoppe", status: "enabled")
    @discount1 = create(:bulk_discount, percent_off: 10, threshold: 5, merchant_id: @merchant1.id)
    @discount2 = create(:bulk_discount, percent_off: 15, threshold: 7, merchant_id: @merchant1.id)
    @discount3 = create(:bulk_discount, percent_off: 20, threshold: 10, merchant_id: @merchant1.id)
    @discount4 = create(:bulk_discount, percent_off: 25, threshold: 15, merchant_id: @merchant1.id)
  end

  describe "User story 4" do
    it 'displays the discount percentage and quantity threshold' do
      visit merchant_bulk_discount_path(@merchant1.id, @discount4.id)

      expect(page).to have_content("Discount Percentage: #{@discount4.percent_off}")
      expect(page).to have_content("Item Quantity to Receive Discount: #{@discount4.threshold}")
    end
  end

  describe "User story 5" do
    it 'has a link on the show page to edit the discount' do
      visit merchant_bulk_discount_path(@merchant1.id, @discount2.id)

      expect(page).to have_link "Edit This Discount", href: edit_merchant_bulk_discount_path(@merchant1.id, @discount2.id)
      click_link "Edit This Discount"
      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1.id, @discount2.id))
    end


  end


end