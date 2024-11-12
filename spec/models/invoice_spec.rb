require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should belong_to(:coupon).optional }
    it { should have_many(:invoice_items).dependent(:destroy)}
    it { should have_many(:transactions).dependent(:destroy)}
  end 

  describe 'validations' do
    it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
  end

    before(:each) do
      @merchant = Merchant.create!(name: 'Merchant 1')
      @customer = Customer.create!(first_name: 'John', last_name: 'Doe')
      @coupon = Coupon.create!(name: 'Holiday Discount', code: 'HOLIDAY', discount_value: 10, discount_type: 'dollar', merchant: @merchant)
      
      # Create invoices
      @invoice_with_coupon = Invoice.create!(merchant: @merchant, customer: @customer, coupon: @coupon, status: 'packaged')
      @invoice_without_coupon = Invoice.create!(merchant: @merchant, customer: @customer, coupon: nil, status: 'packaged')

      # Create items
      @item1 = Item.create!(name: 'Item 1', description: 'Description 1', unit_price: 5, merchant: @merchant)
      @item2 = Item.create!(name: 'Item 2', description: 'Description 2', unit_price: 3, merchant: @merchant)

      # Manually create invoice items using regular global variables
      @invoice_item1 = InvoiceItem.create!(invoice: @invoice_with_coupon, item: @item1, quantity: 2, unit_price: @item1.unit_price) # Total = 10
      @invoice_item2 = InvoiceItem.create!(invoice: @invoice_with_coupon, item: @item2, quantity: 1, unit_price: @item2.unit_price) # Total = 3
    end

    it 'can be created without a coupon' do
      expect(@invoice_without_coupon.coupon).to be(nil)
    end

    it 'can be created with a coupon' do
      expect(@invoice_with_coupon.coupon).to be(@coupon)
    end

    context 'calculating adjusted totals' do
      it 'adjusts the total amount correctly when a dollar-off coupon is applied' do
        # Total: 10 + 3 = 13, Coupon: 10, Adjusted Total: 3
        expect(@invoice_with_coupon.adjusted_total).to eq(3)
      end

      it 'adjusts the total amount to zero if the coupon exceeds the total' do
        # Increase the coupon value to 20, which exceeds the total
        @coupon.update(discount_value: 20)
        expect(@invoice_with_coupon.adjusted_total).to eq(0)
      end

      it 'returns the total amount without any adjustments if no coupon is applied' do
        @invoice_item3 = InvoiceItem.create!(invoice: @invoice_without_coupon, item: @item1, quantity: 1, unit_price: @item1.unit_price) # Total = 5
        expect(@invoice_without_coupon.adjusted_total).to eq(5)
      end
    end
  end

