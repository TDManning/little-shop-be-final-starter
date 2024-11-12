class Api::V1::Merchants::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.fetch_invoices(params[:status])

    render json: InvoiceSerializer.new(invoices), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: ErrorSerializer.format_errors(['Merchant not found']), status: :not_found
  end

  def show
    invoice = Invoice.find(params[:id])

    render json: InvoiceSerializer.new(invoice), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: ErrorSerializer.format_errors(['Invoice not found']), status: :not_found
  end
end