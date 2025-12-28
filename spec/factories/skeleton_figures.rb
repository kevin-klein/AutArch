FactoryBot.define do
  factory :skeleton_figure do
    association :grave
    deposition_type { "primary" }
    x { rand(100..1000) }
    y { rand(100..1000) }
    width { rand(50..200) }
    height { rand(50..200) }

    trait :with_keypoints do
      after(:create) do |skeleton|
        create_list(:key_point, 5, skeleton: skeleton)
      end
    end
  end
end
