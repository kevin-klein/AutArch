# frozen_string_literal: true

module Types
  class SkeletonFigureType < Types::BaseObject
    field :id, ID, null: false
    field :figure_id, Integer
    field :grave_id, Integer
    # field :skeleton_id, ID
    # def skeleton_id
    #   object.skeleton.id
    # end

    field :grave, Types::GraveType
  end
end
