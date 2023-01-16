require 'rails_helper'

RSpec.describe "bulk discount edit page" do
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

  describe "User Story 5" do
    it 'has a form to edit the discount selected with the current attributes already filled in' do
      visit edit_merchant_bulk_discount_path(@merchant1.id, @discount2.id)

      expect(page).to have_content("Edit this Discount:")
      expect(page).to have_field :percent_off, with: @discount2.percent_off
      expect(page).to have_field :threshold, with: @discount2.threshold
    end

    it 'modifies the appropriate discount when submitted and redirects to the discount show page' do
      visit edit_merchant_bulk_discount_path(@merchant1.id, @discount4.id)

      fill_in :percent_off, with: 4
      fill_in :threshold, with: 90

      click_button "Submit"
      
      expect(current_path).to eq(merchant_bulk_discount_path(@merchant1.id, @discount4.id))
      expect(page).to have_content("Discount Percentage: 4")
      expect(page).to have_content("Item Quantity to Receive Discount: 90")
      expect(page).to_not have_content("Discount Percentage: #{@discount4.percent_off}")
      expect(page).to_not have_content("Item Quantity to Receive Discount: #{@discount4.threshold}")
    end



  end




end