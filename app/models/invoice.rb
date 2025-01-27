class Invoice < ApplicationRecord
  belongs_to :customer 
  has_many :transactions, dependent: :delete_all
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  validates_presence_of :status

  enum status: {cancelled: 0,
                completed: 1,
                in_progress: 2}

  def format_date_long
    self.created_at.to_formatted_s(:admin_invoice_date)
  end

  def self.find_unshipped
    self.joins(:invoice_items)
    .where.not(invoice_items: {status: "shipped"})
  end

  def self.sort_by_created_date
    order(:created_at)
  end

  def total_revenue
    self.invoice_items.sum("unit_price * quantity") / 100.00
  end

  def discounted_items(merchant_id)
    self.invoice_items.joins(:bulk_discounts)
        .where(merchants: {id: merchant_id})
        .where("invoice_items.quantity >= bulk_discounts.threshold")
        .group(:id)
        .select("max(bulk_discounts.percent_off) as max_discount, invoice_items.*")
  end

  def non_discounted_items(merchant_id)
    self.invoice_items.joins(:bulk_discounts)
        .group(:id)
        .having("invoice_items.quantity < min(bulk_discounts.threshold)")
        .where(merchants: {id: merchant_id})
  end

  def disc_item_revenue(merchant_id)
    discounted_items(merchant_id).sum do |ii|
      ii.quantity * (ii.unit_price - (ii.unit_price * ii.max_discount / 100)) / 100.00
    end
  end

  def non_disc_item_revenue(merchant_id)
    non_discounted_items(merchant_id).sum do |ii|
      ii.quantity * ii.unit_price / 100.00
    end
  end

  def total_disc_revenue(merchant_id)
    disc_item_revenue(merchant_id) + non_disc_item_revenue(merchant_id)
  end

  def total_invoice_disc_rev
    
    inv_disc_item_revenue + inv_non_disc_item_revenue
  end

  def inv_disc_item_revenue
    inv_discounted_items.sum do |ii|
      ii.quantity * (ii.unit_price - (ii.unit_price * ii.max_discount / 100)) / 100.00
    end
  end

  def inv_non_disc_item_revenue
    inv_non_discounted_items.sum do |ii|
      ii.quantity * ii.unit_price / 100.00
    end
  end

  def inv_discounted_items
    self.invoice_items.joins(:bulk_discounts)
        .where("invoice_items.quantity >= bulk_discounts.threshold")
        .group(:id)
        .select("max(bulk_discounts.percent_off) as max_discount, invoice_items.*")
  end

  def inv_non_discounted_items
    self.invoice_items.joins(:bulk_discounts)
        .group(:id)
        .having("invoice_items.quantity < min(bulk_discounts.threshold)")
  end
end

