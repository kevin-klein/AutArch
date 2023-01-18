# frozen_string_literal: true

module Types
  class FigureType < Types::BaseObject
    field :id, ID, null: false
    field :page_id, Integer, null: false
    field :x1, Integer, null: false
    field :x2, Integer, null: false
    field :y1, Integer, null: false
    field :y2, Integer, null: false
    field :label, String, null: false
    def label
      object.type_name
    end
    field :tags, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
