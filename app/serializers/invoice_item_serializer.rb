class InvoiceItemSerializer
  include JSONAPI::Serializer
  attributes :id, :item_id, :invoice_id, :quantity, :unit_price, :created_at, :updated_at

  attribute :item_name do |invoice_item|
    invoice_item.item.name
  end
end