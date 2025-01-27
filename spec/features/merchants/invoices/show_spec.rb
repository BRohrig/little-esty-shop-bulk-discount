require 'rails_helper'

RSpec.describe 'merchant invoice show' do
  
  describe '/merchants/merchant_id/invoices/invoice_id' do
    before(:each) do
      BulkDiscount.delete_all
      Transaction.delete_all
      InvoiceItem.delete_all
      Invoice.delete_all
      Item.delete_all
      Customer.delete_all
      Merchant.delete_all

      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @merchant_3 = create(:merchant)

      @item_1 = create(:item, merchant: @merchant_1, name: "Purple Test Item")
      @item_2 = create(:item, merchant: @merchant_2)
      @item_3 = create(:item, merchant: @merchant_2, name: "Fuzzy Test Item")
      @item_4 = create(:item, merchant: @merchant_2)
      @item_5 = create(:item, merchant: @merchant_2)
      @item_6 = create(:item, merchant: @merchant_2)
      @item_7 = create(:item, merchant: @merchant_3)
      @item_8 = create(:item, merchant: @merchant_3)
      @item_9 = create(:item, merchant: @merchant_3)
      @item_10 = create(:item, merchant: @merchant_3)

      @customer_1 = create(:customer)
      @customer_2 = create(:customer)

      @invoice_1 = create(:invoice, customer: @customer_1)
      @invoice_2 = create(:invoice, customer: @customer_1)
      @invoice_3 = create(:invoice, customer: @customer_1)
      @invoice_4 = create(:invoice, customer: @customer_2)

      @invoice_item_1 = create(:invoice_item, item: @item_1, invoice: @invoice_1)
      @invoice_item_2 = create(:invoice_item, item: @item_2, invoice: @invoice_2)
      @invoice_item_3 = create(:invoice_item, item: @item_3, invoice: @invoice_3, status: 0)
      @invoice_item_4 = create(:invoice_item, item: @item_4, invoice: @invoice_3, status: 1) 
      @invoice_item_5 = create(:invoice_item, item: @item_5, invoice: @invoice_4)
      @invoice_item_6 = create(:invoice_item, item: @item_7, invoice: @invoice_4)
    end

    it 'shows all information related to that invoice including invoice id, invoice status, invoice creation date, customer name' do
      visit merchant_invoice_path(@merchant_2, @invoice_2)

      expect(page).to have_content(@invoice_2.id)
      expect(page).to have_content(@invoice_2.status)
      expect(page).to have_content(@invoice_2.created_at.to_formatted_s(:admin_invoice_date))
      expect(page).to have_content(@invoice_2.customer.first_name)
      expect(page).to have_content(@invoice_2.customer.last_name)
      expect(page).to_not have_content(@invoice_1.id)
    end

    it 'shows all items on an invoice and their attributes including item name, quantity, sale price, invoice item status' do
      visit merchant_invoice_path(@merchant_2, @invoice_3)
    
      expect(page).to have_content(@invoice_3.id)
      expect(page).to have_content(@item_3.name)
      expect(page).to have_content((@invoice_item_3.unit_price / 100.00))
      expect(page).to have_content(@invoice_item_3.quantity)
      expect(page).to_not have_content(@item_1.name)
    end

    it 'shows total revenue for all items on invoice' do
      visit merchant_invoice_path(@merchant_2, @invoice_3)

      expect(page).to have_content("Invoice Total: $#{@invoice_3.total_revenue}")

      visit merchant_invoice_path(@merchant_1, @invoice_1)

      expect(page).to have_content("Invoice Total: $#{@invoice_1.total_revenue}")
      expect(page).to_not have_content("Invoice Total: $#{@invoice_3.total_revenue}")
    end

    it 'shows each invoice items status is a select field and item current status is selected' do
      visit merchant_invoice_path(@merchant_2, @invoice_3)

      within "#item-#{@invoice_item_3.id}" do
        expect(page).to have_select("status", selected: "packaged")
        expect(page).to_not have_select("status", selected: "pending")
        
        select("shipped", from: "status")
        click_on "Update Item Status"
      end
      
      expect(current_path).to eq("/merchants/#{@merchant_2.id}/invoices/#{@invoice_3.id}")
      expect(page).to have_select("status", selected: "shipped")
    end
  end

  describe "solo user story 6" do
    before(:each) do
      InvoiceItem.delete_all
      BulkDiscount.delete_all
      Transaction.delete_all
      Item.delete_all
      Invoice.delete_all
      Customer.delete_all
      Merchant.delete_all
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @item1 = create(:item, merchant: @merchant)
      @item2 = create(:item, merchant: @merchant)
      @item3 = create(:item, merchant: @merchant)
      @item4 = create(:item, merchant: @merchant2)
      @customer = create(:customer)
      @invoice = create(:invoice, customer: @customer)
      @invoice_item1 = create(:invoice_item, item: @item1, invoice: @invoice, quantity: 5, unit_price: 5000)
      @invoice_item2 = create(:invoice_item, item: @item1, invoice: @invoice, quantity: 10, unit_price: 2500)
      @invoice_item3 = create(:invoice_item, item: @item2, invoice: @invoice, quantity: 5, unit_price: 5000)
      @invoice_item4 = create(:invoice_item, item: @item2, invoice: @invoice, quantity: 25, unit_price: 10000)
      @invoice_item5 = create(:invoice_item, item: @item3, invoice: @invoice, quantity: 20, unit_price: 6000)
      @invoice_item6 = create(:invoice_item, item: @item3, invoice: @invoice, quantity: 35, unit_price: 15000)
      @invoice_item7 = create(:invoice_item, item: @item4, invoice: @invoice, quantity: 21, unit_price: 42000)
      @bulk_discount1 = create(:bulk_discount, merchant: @merchant, percent_off: 10, threshold: 8)
      @bulk_discount2 = create(:bulk_discount, merchant: @merchant, percent_off: 20, threshold: 20)
      @bulk_discount3 = create(:bulk_discount, merchant: @merchant, percent_off: 30, threshold: 30)
      @bulk_discount4 = create(:bulk_discount, merchant: @merchant, percent_off: 15, threshold: 25)
      @bulk_discount5 = create(:bulk_discount, merchant: @merchant2, percent_off: 8, threshold: 15)
    end

    it 'displays the discounted revenue next to the raw revenue' do
      visit merchant_invoice_path(@merchant, @invoice)
      expect(page).to have_content("Total Revenue After Discounts: $7360.0")
    end

    it 'has a link to the applied discount next to each item' do
      visit merchant_invoice_path(@merchant, @invoice)

      within "#item-#{@invoice_item1.id}" do
        expect(page).to_not have_link("Discount Applied")
      end

      within "#item-#{@invoice_item2.id}" do
        expect(page).to have_link("Discount Applied", href: merchant_bulk_discount_path(@merchant.id, @bulk_discount1.id))
      end

      within "#item-#{@invoice_item6.id}" do
        expect(page).to have_link("Discount Applied", href: merchant_bulk_discount_path(@merchant.id, @bulk_discount3.id))
      end
    end

  end
end