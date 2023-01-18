# frozen_string_literal: true

module Types
  class GraveType < Types::BaseObject
    field :id, ID, null: false
    field :location, String
    field :figure_id, Integer, null: false
    field :site_id, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :arc_length, Float
    field :area, Float
    field :kurgan_id, Integer
    field :figures, [FigureType]

    field :page, PageType
  end
end
