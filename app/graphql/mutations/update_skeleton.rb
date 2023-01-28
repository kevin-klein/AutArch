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
      data[:chronology_attributes] = data.delete(:chronology) if data[:chronology].present?
      data[:stable_isotopes_attributes] = data.delete(:stable_isotopes) if data[:stable_isotopes].present?
      data[:anthropology_attributes] = data.delete(:anthropology) if data[:anthropology].present?
      data[:taxonomy_attributes] = data.delete(:taxonomy) if data[:taxonomy].present?
      data[:genetics_attributes] = data.delete(:genetics) if data[:genetics].present?

      data[:chronology_attributes][:c14_dates_attributes] = data[:chronology_attributes].delete(:c14_dates) if data[:chronology_attributes].present? && data[:chronology_attributes][:c14_dates].present?

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
