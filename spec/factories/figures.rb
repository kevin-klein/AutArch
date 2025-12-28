FactoryBot.define do
  factory :figure do
    association :grave
    x1 { rand(100..1000) }
    y1 { rand(100..1000) }
    width { rand(50..200) }
    height { rand(50..200) }
    angle { rand(0..360) }
  end
end
