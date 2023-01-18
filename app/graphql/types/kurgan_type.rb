# frozen_string_literal: true

module Types
  class KurganType < Types::BaseObject
    field :id, ID, null: false
    field :width, Integer
    field :height, Integer
    field :name, String, null: false
    field :publication_id, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
