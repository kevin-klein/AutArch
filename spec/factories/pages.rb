FactoryBot.define do
  factory :page do
    number { rand(1..100) }
    association :publication
  end
end
