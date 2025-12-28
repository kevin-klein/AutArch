FactoryBot.define do
  factory :scale do
    # association :grave
    text { "1:50" }
    x1 { rand(100..1000) }
    y1 { rand(100..1000) }
    x2 { rand(100..1000) }
    y2 { rand(100..1000) }
    width { rand(50..200) }
    height { rand(50..200) }
  end
end
