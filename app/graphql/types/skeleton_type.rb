# frozen_string_literal: true

module Types
  class SkeletonType < Types::BaseObject
    field :id, ID, null: false
    field :grave_id, ID, null: false
    field :skeleton_figure_id, ID, null: false
    field :skeleton_id, String
    field :angle, Float
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :location, LocationType
    def location
      object.site
    end

    field :anthropology, AnthropologyType, null: true
    field :skeleton_figure, SkeletonFigureType, null: true
    field :chronology, ChronologyType, null: true
    field :taxonomy, TaxonomyType, null: true
    field :genetics, [GeneticType], null: false

    field :stable_isotopes, [StableIsotopeType], null: false
  end
end
