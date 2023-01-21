module Types
  class MutationType < Types::BaseObject
    field :update_skeleton, mutation: Mutations::UpdateSkeleton
    field :delete_mt_haplogroup, mutation: Mutations::DeleteMtHaplogroup
    field :delete_y_haplogroup, mutation: Mutations::DeleteYHaplogroup
    field :create_y_haplogroup, mutation: Mutations::CreateYHaplogroup
    field :create_mt_haplogroup, mutation: Mutations::CreateMtHaplogroup
    field :delete_culture, mutation: Mutations::DeleteCulture
    field :create_culture, mutation: Mutations::CreateCulture
    field :delete_period, mutation: Mutations::DeletePeriod
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end

    field :create_period, mutation: Mutations::CreatePeriodMutation
  end
end
