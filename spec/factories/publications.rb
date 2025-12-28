FactoryBot.define do
  factory :publication do
    title { SecureRandom.hex(12) }
    author { SecureRandom.hex(12) }
  end
end
