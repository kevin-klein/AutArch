module Mutations
  class CreateCulture < BaseMutation
    # TODO: define return fields
    # field :post, Types::PostType, null: false
    argument :name, String

    field :culture, Types::CultureType
    # TODO: define arguments
    # argument :name, String, required: true

    # TODO: define resolve method
    def resolve(name:)
      culture = Culture.create!(name: name)
      { culture: culture }
    end
  end
end
