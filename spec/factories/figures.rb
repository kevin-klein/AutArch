FactoryBot.define do
  factory :figure do
    association :page
    x1 { rand(100..1000) }
    y1 { rand(100..1000) }
    width { rand(50..200) }
    height { rand(50..200) }
    angle { rand(0..360) }
    probability { 0.9 }
    contour { [[10, 10], [100, 10], [100, 100], [10, 100]] }

    factory :ceramic do
      type { 'Ceramic' }
    end

    factory :stone_tool do
      type { 'StoneTool' }
    end

    factory :spine do
      type { 'Spine' }
      x1 { 100 }
      y1 { 100 }
      x2 { 200 }
      y2 { 150 }
    end

    factory :object_similarity do
      first { create(:figure) }
      second { create(:figure) }
      similarity { rand(0..100).to_f / 100 }
    end
  end
end
