module Mutations
  class CreateYHaplogroup < BaseMutation
    argument :name, String, required: true

    field :y_haplogroup, Types::YHaplogroupType

    # TODO: define resolve method
    def resolve(name:)
      y_haplogroup = YHaplogroup.create!(name: name)
      { y_haplogroup: y_haplogroup }
    end
  end
end
