FactoryBot.define do
  factory :grave do
    identifier { "GRAVE_#{SecureRandom.hex(4).upcase}" }
    probability { 0.7 }
    percentage_scale { "100:1" }
    page_size { "A4" }
    x1 { rand(100..1000) }
    y1 { rand(100..1000) }
    x2 { rand(100..1000) }
    y2 { rand(100..1000) }
    # association :site
    # association :scale
    # association :arrow
    # association :page
    # association :publication

    trait :with_skeleton do
      after(:create) do |grave|
        create(:skeleton_figure, grave: grave)
      end
    end

    trait :with_figures do
      after(:create) do |grave|
        create(:figure, grave: grave)
      end
    end
  end
end
