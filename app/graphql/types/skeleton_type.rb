# frozen_string_literal: true

module Types
  class SkeletonType < Types::BaseObject
    field :id, ID, null: false
    field :grave_id, Integer, null: false
    field :figure_id, Integer, null: false
    field :skeleton_id, String
    field :angle, Float
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :grave, GraveType
    field :location, LocationType
    def location
      object.grave.site
    end

    field :anthropology, AnthropologyType, null: true
    field :figure, FigureType, null: true
    field :chronology, ChronologyType, null: true
    field :taxonomy, TaxonomyType, null: true
  end
end
