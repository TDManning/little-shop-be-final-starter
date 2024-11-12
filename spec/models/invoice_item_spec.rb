require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'validations' do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
  end

  describe 'custom validations' do
    before(:each) do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @customer = create(:customer)
      @coupon = create(:coupon, merchant: @merchant2, code: 'HOLIDAY', discount_value: 10, discount_type: 'percent')

      @invoice = create(:invoice, customer: @customer, merchant: @merchant2, coupon: @coupon, status: 'packaged')
    end

    context 'when adding items to an invoice with a coupon' do
      it 'raises a validation error if the item belongs to a different merchant than the coupon' do
        @item1 = create(:item, merchant: @merchant1, unit_price: 100)

        expect {
          InvoiceItem.create!(invoice: @invoice, item: @item1, quantity: 1, unit_price: @item1.unit_price)
        }.to raise_error(ActiveRecord::RecordInvalid, /Item can only be applied to items sold by the same merchant as the coupon/)
      end

      it 'allows the creation if the item belongs to the same merchant as the coupon' do
        @item2 = create(:item, merchant: @merchant2, unit_price: 100)

        invoice_item = InvoiceItem.new(invoice: @invoice, item: @item2, quantity: 1, unit_price: @item2.unit_price)

        expect(invoice_item.valid?).to be_truthy
        expect(invoice_item.errors[:item]).to be_empty
      end
    end
  end
end
