FactoryBot.define do
  factory :page do
    number { rand(1..100) }
    association :publication
    association :image

    factory :page_with_figure do
      transient { figure_count { 1 } }

      after(:create) do |page, evaluator|
        create_list(:figure, evaluator.figure_count, page: page)
      end
    end
  end
end
