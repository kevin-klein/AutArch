module Mutations
  class UpdateSkeleton < BaseMutation
    # TODO: define return fields
    field :id, ID, null: false
    # field :post, Types::PostType, null: false

    argument :id, Int, required: true
    argument :skeleton, Types::SkeletonInputType, required: true

    def resolve(id:, skeleton:)
      db_skeleton = Skeleton.find(id)

      data = skeleton.to_h
      data[:chronology_attributes] = data.delete(:chronology)
      data[:stable_isotopes_attributes] = data.delete(:stable_isotopes)
      data[:anthropology_attributes] = data.delete(:anthropology)
      data[:taxonomy_attributes] = data.delete(:taxonomy)
      data[:genetics_attributes] = data.delete(:genetics)

      data[:chronology_attributes][:c14_dates_attributes] = data[:chronology_attributes].delete(:c14_dates)

      site = data.delete(:location)

      unless db_skeleton.update(data)
        raise GraphQL::ExecutionError, db_skeleton.errors.full_messages
      end

      {
        id:
      }
    end
  end
end
