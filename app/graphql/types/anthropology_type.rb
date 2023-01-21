# frozen_string_literal: true

module Types
  class AnthropologyType < Types::BaseObject
    field :id, ID, null: false
    field :sex_morph, Integer
    field :sex_gen, Integer
    field :sex_consensus, Integer
    field :age_as_reported, String
    field :age_class, Integer
    field :height, Float
    field :pathologies_type, String
    field :skeleton_id, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
