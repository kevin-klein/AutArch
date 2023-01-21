module Mutations
  class DeleteYHaplogroup < BaseMutation
    argument :id, String, required: true

    field :id, String

    def resolve(id:)
      YHaplogroup.find(id).destroy!
      {
        id: id
      }
    end
  end
end
