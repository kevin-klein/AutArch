module Mutations
  class UpdateGrave < BaseMutation
    argument :id, ID, required: true
    argument :grave, Types::GraveInputType

    field :id, String

    def resolve(id:)
      YHaplogroup.find(id).destroy!
      {
        id: id
      }
    end
  end
end
