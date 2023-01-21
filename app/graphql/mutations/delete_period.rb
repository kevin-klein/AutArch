module Mutations
  class DeletePeriod < BaseMutation
    # TODO: define arguments
    argument :id, String, required: true

    field :id, String

    # TODO: define resolve method
    def resolve(id:)
      Period.find(id).destroy!
      {
        id: id
      }
    end
  end
end
