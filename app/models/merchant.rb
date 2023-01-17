class Merchant < ApplicationRecord
  has_many :bulk_discounts, dependent: :delete_all
  has_many :items, dependent: :delete_all
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  validates_presence_of :name

  enum status: { enabled: 0, disabled: 1 }

  def top_customers
            Customer.select("customers.*, COUNT (transactions.id) AS trans_count")
            .distinct
            .joins(invoices: [:transactions, :merchants])
            .where("transactions.result = 0 AND merchants.id = ?", self.id)
            .group("merchants.id, customers.id")
            .order(trans_count: :desc)
            .limit(5)
  end

  def toggle_status
    self.status == "enabled" ? self.disabled! : self.enabled!
  end

  def self.group_by_status(status)
    self.where(status: status)
  end

  def top_5_revenue_items
    self.items
        .joins(:transactions)
        .group(:id)
        .where(transactions: { result: "success" })
        .order(Arel.sql("sum(invoice_items.unit_price * invoice_items.quantity) desc"))
        .limit(5)
      end
        
  def self.top_five #merchant
    self.joins(:invoice_items, :transactions)
        .where('result = 0')
        .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue')
        .group(:id)
        .order('total_revenue desc')
        .limit(5)
  end

  def total_revenue
    self.invoices
        .joins(:invoice_items, :transactions)
        .where('transactions.result = 0')
        .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def best_day
    self.invoices
        .where("invoices.status = 2")
        .joins(:invoice_items)
        .select('invoices.id, invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as total_revenue')
        .group("invoices.id, invoices.created_at")
        .order("total_revenue desc", "invoices.created_at desc")
        .limit(1)
        .first
  end

  def unshipped_items
    self.items.joins(invoices: [invoice_items: :merchant])
    .where("invoice_items.status != 2 AND merchants.id = ?", self.id)
    .select("invoice_items.status AS shipping_status, items.name, invoice_items.invoice_id AS inv_num")
    .group("items.id, merchants.id, invoice_items.invoice_id, invoice_items.status, invoices.created_at")
    .order("invoices.created_at asc")
    .pluck("items.name, invoice_items.invoice_id, invoices.created_at")
  end 

end
