FactoryBot.define do
  factory :bulk_discount do
    percent_off {[5, 10, 15, 20, 25, 30, 35].sample}
    threshold {[5, 10, 15].sample}
  end
end