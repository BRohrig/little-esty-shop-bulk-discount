class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  validates :percent_off, :threshold, presence: true
  validates :percent_off, numericality: { only_integer: true }
  validates :threshold, numericality: { only_integer: true }
end