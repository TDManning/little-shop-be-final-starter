require 'rails_helper'

RSpec.describe "Invoice Items API", type: :request do
  before(:each) do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    @customer = create(:customer)

    @coupon = create(:coupon, merchant: @merchant2, code: 'HOLIDAY', discount_value: 15, discount_type: 'percent', active: true)
    @invoice = create(:invoice, customer: @customer, merchant: @merchant2, coupon: @coupon)

    @item1 = create(:item, merchant: @merchant1, unit_price: 100)
    @item2 = create(:item, merchant: @merchant2, unit_price: 150)
  end

  context "when adding items to an invoice with a coupon" do
    it "returns an error if the item belongs to a different merchant than the coupon" do
      post "/api/v1/merchants/#{@merchant2.id}/invoices/#{@invoice.id}/invoice_items", params: {
        item_id: @item1.id,
        quantity: 1,
        unit_price: @item1.unit_price
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to include("Item can only be applied to items sold by the same merchant as the coupon")
    end

    it "creates an invoice item if the item belongs to the same merchant as the coupon" do
      post "/api/v1/merchants/#{@merchant2.id}/invoices/#{@invoice.id}/invoice_items", params: {
        item_id: @item2.id,
        quantity: 1,
        unit_price: @item2.unit_price
      }

      expect(response).to have_http_status(:created)
    end
  end
end
