module Mutations
  class CreateMtHaplogroup < BaseMutation
    argument :name, String, required: true

    field :mt_haplogroup, Types::MtHaplogroupType

    # TODO: define resolve method
    def resolve(name:)
      mt_haplogroup = MtHaplogroup.create!(name: name)
      { mt_haplogroup: mt_haplogroup }
    end
  end
end
