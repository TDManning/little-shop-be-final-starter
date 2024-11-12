class Api::V1::Merchants::InvoiceItemsController < ApplicationController
  def create
    invoice = Invoice.find(params[:invoice_id])
    item = Item.find(params[:item_id])

    invoice_item = InvoiceItem.new(
      invoice: invoice,
      item: item,
      quantity: params[:quantity],
      unit_price: params[:unit_price]
    )

    if invoice_item.save
      render json: InvoiceItemSerializer.new(invoice_item), status: :created
    else
      render json: { errors: invoice_item.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

