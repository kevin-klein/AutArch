module Mutations
  class UpateGrave < BaseMutation
    argument :id, ID, required: true
    argument :grave, GraveInputType

    field :id, String

    def resolve(id:)
      YHaplogroup.find(id).destroy!
      {
        id: id
      }
    end
  end
end
