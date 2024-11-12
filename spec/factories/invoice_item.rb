FactoryBot.define do
  factory :invoice_item do
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }

    association :invoice
    association :item
  end
end