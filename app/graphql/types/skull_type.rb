# frozen_string_literal: true

module Types
  class SkullType < Types::BaseObject
    field :id, ID, null: false
    field :skeleton_id, Integer, null: false
    field :figure_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
