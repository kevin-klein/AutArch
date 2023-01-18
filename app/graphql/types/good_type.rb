# frozen_string_literal: true

module Types
  class GoodType < Types::BaseObject
    field :id, ID, null: false
    field :grave_id, Integer, null: false
    field :figure_id, Integer, null: false
    field :type, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
