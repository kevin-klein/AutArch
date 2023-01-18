# frozen_string_literal: true

module Types
  class ScaleType < Types::BaseObject
    field :id, ID, null: false
    field :figure_id, Integer, null: false
    field :grave_id, Integer, null: false
    field :meter_ratio, Float
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
