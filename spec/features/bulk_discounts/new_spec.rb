require 'rails_helper'

RSpec.describe "bulk discount new page" do
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

  it 'has a form to fill out to create a new discount' do
    visit merchant_bulk_discounts_path(@merchant1.id)
    expect(page).to_not have_content("This Discount Gives 90% off if the customer buys 2 items")

    visit new_merchant_bulk_discount_path(@merchant1.id)

    expect(page).to have_field :percent_off
    expect(page).to have_field :threshold
    fill_in :percent_off, with: 90
    fill_in :threshold, with: 2

    click_button "Create Discount"
    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1.id))
     
    within "#discounts" do
      expect(page).to have_content("This Discount Gives 90% off if the customer buys 2 items")
    end

  end

end