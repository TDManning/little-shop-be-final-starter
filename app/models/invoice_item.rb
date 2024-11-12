class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  validates :quantity, presence: true
  validates :unit_price, presence: true

  validate :item_merchant_matches_invoice_coupon

private

def item_merchant_matches_invoice_coupon
  return if invoice.nil? || invoice.coupon.nil?
  
  unless item.merchant_id == invoice.coupon.merchant_id
    errors.add(:item, "can only be applied to items sold by the same merchant as the coupon")
  end
end
end