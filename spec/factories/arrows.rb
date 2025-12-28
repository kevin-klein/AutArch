FactoryBot.define do
  factory :arrow do
    # association :grave
    x { rand(100..1000) }
    y { rand(100..1000) }
    width { rand(50..200) }
    height { rand(50..200) }
    angle { 0 }
  end
end
