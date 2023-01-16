class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_one :merchant, through: :item
  has_many :bulk_discounts, through: :merchant
  has_one :customer, through: :invoice

  enum status: {packaged: 0,
                pending: 1,
                shipped: 2}

  def self.revenue
    self.sum("(quantity * unit_price) / 100.00")
  end

  def find_discount
    self.bulk_discounts
    .where("bulk_discounts.threshold <= ?", self.quantity)
    .order(percent_off: :desc)
    .first
  end
end