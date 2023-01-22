# frozen_string_literal: true

module Types
  class GraveType < Types::BaseObject
    field :id, ID, null: false
    field :location, String
    field :figure_id, ID, null: false
    field :site_id, ID
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :arc_length, Float
    field :area, Float
    field :kurgan_id, ID
    field :figures, [FigureType]

    field :area_with_unit, UnitValueType
    field :arc_length_with_unit, UnitValueType

    field :arrow, ArrowType

    field :page, PageType
  end
end
