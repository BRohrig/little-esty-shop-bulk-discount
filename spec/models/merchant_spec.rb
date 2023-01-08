require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it {should have_many(:items)}
    it {should have_many(:invoice_items).through(:items)}
    it {should have_many(:invoices).through(:invoice_items)}
    it {should have_many(:transactions).through(:invoices)}
    it {should have_many(:customers).through(:invoices)}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
  end

  before(:each) do
    @merchant_1 = create(:merchant, name: "merchant 1")
    @merchant_2 = create(:merchant, name: "merchant 2")
    @merchant_3 = create(:merchant, name: "merchant 3")
    @merchant_4 = create(:merchant, name: "merchant 4")

    @item_1 = create(:item, merchant: @merchant_1)
    @item_2 = create(:item, merchant: @merchant_2)
    @item_3 = create(:item, merchant: @merchant_2)
    @item_4 = create(:item, merchant: @merchant_2)
    @item_5 = create(:item, merchant: @merchant_2)
    @item_6 = create(:item, merchant: @merchant_2)
    @item_7 = create(:item, merchant: @merchant_3)
    @item_8 = create(:item, merchant: @merchant_3)
    @item_9 = create(:item, merchant: @merchant_3)
    @item_10 = create(:item, merchant: @merchant_3)
    @item_11 = create(:item, name: "testing item", merchant: @merchant_4)

    @customer_1 = create(:customer, first_name: "Customer 1")
    @customer_2 = create(:customer, first_name: "Customer 2")
    @customer_3 = create(:customer, first_name: "Customer 3")
    @customer_4 = create(:customer, first_name: "Customer 4")
    @customer_5 = create(:customer, first_name: "Customer 5")
    @customer_6 = create(:customer, first_name: "Customer 6")
    @customer_7 = create(:customer, first_name: "Customer 7")
    @customer_8 = create(:customer, first_name: "Customer 8")
    @customer_9 = create(:customer, first_name: "Customer 9")

    @invoice_1 = create(:invoice, customer: @customer_1)
    @invoice_1.items << @item_1
    @invoice_2 = create(:invoice, customer: @customer_1)
    @invoice_2.items << @item_2
    @invoice_3 = create(:invoice, customer: @customer_1)
    @invoice_3.items << [@item_3, @item_4]
    @invoice_4 = create(:invoice, customer: @customer_2)
    @invoice_4.items << [@item_5, @item_7]
    
    @invoice_5 = create(:invoice, customer: @customer_3)
    @invoice_5.items << [@item_2, @item_3, @item_6, @item_8]
    @invoice_6 = create(:invoice, customer: @customer_3)
    @invoice_6.items << [@item_2, @item_2, @item_4, @item_6, @item_11, @item_11, @item_11]
    @invoice_7 = create(:invoice, customer: @customer_4)
    @invoice_7.items << [@item_1, @item_1, @item_10, @item_11]
    @invoice_8 = create(:invoice, customer: @customer_5)
    @invoice_8.items << [@item_5, @item_7, @item_10,  @item_11, @item_11, @item_11]
    
    @invoice_9= create(:invoice, customer: @customer_6)
    @invoice_9.items << [@item_1, @item_1, @item_1, @item_1, @item_1, @item_4, @item_7, @item_10, @item_11]
    @invoice_10 = create(:invoice, customer: @customer_7)
    @invoice_10.items << [@item_3, @item_4, @item_5, @item_6,  @item_11, @item_11,  @item_11, @item_11]
    @invoice_11 = create(:invoice, customer: @customer_7)
    @invoice_11.items << [@item_1, @item_10]
    @invoice_12 = create(:invoice, customer: @customer_8)
    @invoice_12.items << [@item_2, @item_3, @item_4, @item_5, @item_5, @item_6, @item_6]
    @invoice_13 = create(:invoice, status: "completed", customer: @customer_9)
    @invoice_13.items << [@item_1, @item_1, @item_1, @item_11, @item_11, @item_11]
    @invoice_14 = create(:invoice, status: "completed", customer: @customer_8)
    @invoice_14.items << [@item_1, @item_11, @item_11]

    @transaction_1 = create(:transaction, invoice: @invoice_1, result: "success")
    @transaction_2 = create(:transaction, invoice: @invoice_2, result: "success")
    @transaction_3 = create(:transaction, invoice: @invoice_3, result: "success")
    @transaction_4 = create(:transaction, invoice: @invoice_4, result: "success")
    @transaction_5 = create(:transaction, invoice: @invoice_5, result: "failed")
    @transaction_6 = create(:transaction, invoice: @invoice_6, result: "success")
    @transaction_7 = create(:transaction, invoice: @invoice_7, result: "success")
    @transaction_8 = create(:transaction, invoice: @invoice_8, result: "success")
    @transaction_9 = create(:transaction, invoice: @invoice_9, result: "failed")
    @transaction_10 = create(:transaction, invoice: @invoice_10, result: "success")
    @transaction_11 = create(:transaction, invoice: @invoice_11, result: "success")
    @transaction_12 = create(:transaction, invoice: @invoice_5, result: "success")
    @transaction_13 = create(:transaction, invoice: @invoice_9, result: "success")
    @transaction_14 = create(:transaction, invoice: @invoice_12, result: "failed")
    @transaction_15 = create(:transaction, invoice: @invoice_13, result: "success")
    @transaction_16 = create(:transaction, invoice: @invoice_14, result: "success")
  
  end

  describe 'merchant invoices' do
    it 'returns merchant invoice ids' do
      expect(@merchant_2.all_invoice_ids).to eq([@invoice_2.id, @invoice_3.id, @invoice_4.id, @invoice_5.id, @invoice_6.id, @invoice_8.id, @invoice_9.id, @invoice_10.id, @invoice_12.id])
    end
  end

  describe 'Merchant the 5 customers' do
    it 'returns only the 5 customers with most successful transactions for a merchant in descending order' do
      expect(@merchant_1.customers.distinct.count).to eq(6)  
      expect(@merchant_4.customers.distinct.count).to eq(7)  

      expect(@merchant_1.top_customers.length).to eq(5)
      expect(@merchant_4.top_customers.length).to eq(5)
      
      expect(@merchant_1.top_customers).to_not eq([@customer_9, @customer_6, @customer_1, @customer_4, @customer_7])
      expect(@merchant_4.top_customers).to_not eq([@customer_7, @customer_3, @customer_9, @customer_5, @customer_8])
      
      expect(@merchant_1.top_customers).to eq([@customer_6, @customer_9, @customer_4, @customer_1, @customer_7])
      expect(@merchant_4.top_customers).to eq([@customer_7, @customer_3, @customer_5, @customer_9, @customer_8])
    end

    it 'returns the number of transactions the customers had' do
      expect(@merchant_1.top_customers.first.trans_count).to eq(5)
      expect(@merchant_1.top_customers.second.trans_count).to eq(3)
      expect(@merchant_1.top_customers.third.trans_count).to eq(2)
      expect(@merchant_1.top_customers.fourth.trans_count).to eq(1)
      expect(@merchant_1.top_customers.last.trans_count).to eq(1)

      expect(@merchant_4.top_customers.first.trans_count).to eq(4)
      expect(@merchant_4.top_customers.second.trans_count).to eq(3)
      expect(@merchant_4.top_customers.third.trans_count).to eq(3)
      expect(@merchant_4.top_customers.fourth.trans_count).to eq(3)
      expect(@merchant_4.top_customers.last.trans_count).to eq(2)
    end

    it 'returns order based on customer.id (asc) if multiple customers have the same number of successful transactions' do 
      expect(@merchant_1.top_customers.fourth).to eq(@customer_1)
      expect(@merchant_1.top_customers.last).to eq(@customer_7)
      
      expect(@merchant_4.top_customers.second).to eq(@customer_3)
      expect(@merchant_4.top_customers.third).to eq(@customer_5)    
      expect(@merchant_4.top_customers.fourth).to eq(@customer_9)    
    end

  end
end