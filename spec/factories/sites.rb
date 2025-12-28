FactoryBot.define do
  factory :site do
    name { "Site #{SecureRandom.hex(3).upcase}" }
    lat { 0 }
    lon { 0 }
  end
end
