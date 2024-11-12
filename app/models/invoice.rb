class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

  def total_amount
    invoice_items.sum do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price
    end
  end

  def adjusted_total
    original_total = total_amount

    if coupon && coupon.discount_type == 'dollar'
      discounted_total = original_total - coupon.discount_value
      return 0 if discounted_total < 0
      return discounted_total
    end

    original_total
  end
end
