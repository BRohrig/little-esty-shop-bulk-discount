require 'rails_helper'

RSpec.describe "bulk discounts index page" do
  before(:all) do
    BulkDiscount.delete_all
    Merchant.delete_all
    @merchant1 = create(:merchant, name: "Ye Olde Test Shoppe", status: "enabled")
    @discount1 = create(:bulk_discount, percent_off: 10, threshold: 5, merchant_id: @merchant1.id)
    @discount2 = create(:bulk_discount, percent_off: 15, threshold: 7, merchant_id: @merchant1.id)
    @discount3 = create(:bulk_discount, percent_off: 20, threshold: 10, merchant_id: @merchant1.id)
    @discount4 = create(:bulk_discount, percent_off: 25, threshold: 15, merchant_id: @merchant1.id)
  end

  describe "user story 1" do
    it 'displays all my bulk discounts including their % off and quantity thresholds' do
      visit merchant_bulk_discounts_path(@merchant1.id)
      
      within "#discounts-#{@discount1.id}" do
        expect(page).to have_content("This Discount Gives #{@discount1.percent_off}% off if the customer buys #{@discount1.threshold} items")
      end

      within "#discounts-#{@discount2.id}" do
        expect(page).to have_content("This Discount Gives #{@discount2.percent_off}% off if the customer buys #{@discount2.threshold} items")
      end

      within "#discounts-#{@discount3.id}" do
        expect(page).to have_content("This Discount Gives #{@discount3.percent_off}% off if the customer buys #{@discount3.threshold} items")
      end

      within "#discounts-#{@discount4.id}" do
        expect(page).to have_content("This Discount Gives #{@discount4.percent_off}% off if the customer buys #{@discount4.threshold} items")
      end
    end

    it 'has links to the bulk discount show pages' do
      visit merchant_bulk_discounts_path(@merchant1.id)

      within "#discounts-#{@discount1.id}" do
        expect(page).to have_link "Details", href: merchant_bulk_discount_path(@merchant1.id, @discount1.id)
        click_link("Details")
        expect(current_path).to eq(merchant_bulk_discount_path(@merchant1.id, @discount1.id))
      end      
    end


  end

end