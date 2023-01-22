# frozen_string_literal: true

module Types
  class GraveCrossSectionType < Types::BaseObject
    field :id, ID, null: false
    field :grave_id, ID, null: false
    field :figure_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
