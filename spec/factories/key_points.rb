FactoryBot.define do
  factory :key_point do
    association :skeleton
    label { ["head", "spine", "pelvis", "knee", "ankle"].sample }
    x { rand(100..1000) }
    y { rand(100..1000) }
  end
end
