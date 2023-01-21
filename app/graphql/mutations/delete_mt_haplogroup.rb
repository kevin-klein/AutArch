module Mutations
  class DeleteMtHaplogroup < BaseMutation
    argument :id, String, required: true

    field :id, String

    def resolve(id:)
      MtHaplogroup.find(id).destroy!
      {
        id: id
      }
    end
  end
end
