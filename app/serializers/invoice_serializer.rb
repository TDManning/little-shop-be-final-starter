class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :customer_id, :status, :coupon_id

  attribute :total_amount do |invoice|
    invoice.total_amount
  end

  attribute :adjusted_total do |invoice|
    invoice.adjusted_total
  end
end