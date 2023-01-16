require 'rails_helper'

RSpec.describe 'the admin show page' do
  before(:all) do
    BulkDiscount.delete_all
    InvoiceItem.delete_all
    Transaction.delete_all
    Invoice.delete_all
    Item.delete_all
    Customer.delete_all
    Merchant.delete_all
    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)

    @invoice_1 = create(:invoice, customer: @customer_1)
    @invoice_2 = create(:invoice, customer: @customer_1)
    @invoice_3 = create(:invoice, customer: @customer_2)
    @invoice_4 = create(:invoice, customer: @customer_5, status: 2)
    @invoice_5 = create(:invoice, customer: @customer_5, status: 2)

    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @merchant_3 = create(:merchant)
    @merchant_4 = create(:merchant)

    @item_1 = create(:item, merchant: @merchant_1)
    @item_2 = create(:item, merchant: @merchant_1)
    @item_3 = create(:item, merchant: @merchant_1)
    @item_4 = create(:item, merchant: @merchant_1)

    @invoice_item_1 = create(:invoice_item, item: @item_1, invoice: @invoice_1, quantity: 7, unit_price: 12000)
    @invoice_item_2 = create(:invoice_item, item: @item_2, invoice: @invoice_1, quantity: 18, unit_price: 42000)
    @invoice_item_3 = create(:invoice_item, item: @item_3, invoice: @invoice_1, quantity: 22, unit_price: 31000)
    @invoice_item_4 = create(:invoice_item, item: @item_4, invoice: @invoice_1, quantity: 32, unit_price: 19000)
    @invoice_item_5 = create(:invoice_item, item: @item_2, invoice: @invoice_2)
    @invoice_item_6 = create(:invoice_item, item: @item_3, invoice: @invoice_2)
    @bulk_discount1 = create(:bulk_discount, merchant: @merchant_1, percent_off: 10, threshold: 8)
      @bulk_discount2 = create(:bulk_discount, merchant: @merchant_1, percent_off: 20, threshold: 20)
      @bulk_discount3 = create(:bulk_discount, merchant: @merchant_1, percent_off: 30, threshold: 30)
  end

  describe 'As an admin, When I visit an admin invoice show page' do
    it 'shows the attributes for the corresponding invoice' do
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content(@invoice_1.status)
      expect(page).to have_content(@invoice_1.created_at.to_formatted_s(:admin_invoice_date))
      expect(page).to have_content(@invoice_1.customer.first_name)
      expect(page).to have_content(@invoice_1.customer.last_name)
    end

    it 'shows all of the items on the invoice' do
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content(@item_1.name)
      expect(page).to have_content(@invoice_item_1.quantity)
      expect(page).to have_content((@invoice_item_1.unit_price / 100.00))
      expect(page).to have_content(@invoice_item_1.status)
    end

    it 'shows the total revenue that will be generated from this invoice' do
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content("Total Revenue: $#{@invoice_1.total_revenue}")

      visit admin_invoice_path(@invoice_2)

      expect(page).to have_content("Total Revenue: $#{@invoice_2.total_revenue}")
    end

    it 'shows the invoice status is a select field and shows the current status is selected' do
      visit admin_invoice_path(@invoice_4)
      
      expect(page).to have_select("status", selected: "in_progress")

      select("completed", from: "status")
      click_on("Update Invoice Status")

      expect(current_path).to eq("/admin/invoices/#{@invoice_4.id}")
      expect(page).to have_select("status", selected: "completed")
    end
  end

  describe "total revenue and discounted revenue display" do
    it "displays the raw revenue and the discounted revenue for the invoice" do
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content("Total Revenue: $21300.0")
      expect(page).to have_content("Total Revenue After Discounts: $17356.0")
    end


  end
end