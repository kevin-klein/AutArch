FactoryBot.define do
  factory :tag do
    name { "Tag #{SecureRandom.hex(3).upcase}" }
  end
end
