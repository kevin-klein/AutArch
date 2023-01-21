module Mutations
  class DeleteCulture < BaseMutation
    argument :id, String, required: true

    field :id, String

    def resolve(id:)
      Culture.find(id).destroy!
      {
        id: id
      }
    end
  end
end
