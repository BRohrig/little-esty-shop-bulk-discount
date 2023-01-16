require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it {should belong_to(:invoice)}
    it {should belong_to(:item)}
    it {should have_one(:merchant).through(:item)}
    it {should have_one(:customer).through(:invoice)}
    it {should have_many(:transactions).through(:invoice)}
    it {should have_many(:bulk_discounts).through(:merchant)}
  end

  before(:all) do
    InvoiceItem.delete_all
    BulkDiscount.delete_all
    Transaction.delete_all
    Item.delete_all
    Invoice.delete_all
    Customer.delete_all
    Merchant.delete_all
    @merchant1 = Merchant.create!(name: "Schroeder-Jerde")
    @item1 = Item.create!(name: "Item 1", unit_price: 75107, description: "it's a thing that does stuff", merchant_id: @merchant1.id)
    @customer1 = Customer.create!(first_name: "Joey", last_name: "Ondricka")
    @invoice1 = Invoice.create!(customer_id: @customer1.id, status: "completed")
    @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 23, unit_price: 2, status: "shipped")
    @bulk_discount1 = create(:bulk_discount, merchant: @merchant1, percent_off: 10, threshold: 8)
    @bulk_discount2 = create(:bulk_discount, merchant: @merchant1, percent_off: 20, threshold: 20)
    @bulk_discount3 = create(:bulk_discount, merchant: @merchant1, percent_off: 30, threshold: 30)
  end

  it 'has a method to find the revenue for instances of itself' do
    expect(InvoiceItem.revenue).to eq(0.46)
  end

  it 'has a method to find the bulk_discount applied to it' do
    expect(@invoice_item1.find_discount).to eq(@bulk_discount2)
  end

end