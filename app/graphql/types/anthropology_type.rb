# frozen_string_literal: true

module Types
  class AnthropologyType < Types::BaseObject
    field :id, ID, null: false
    field :sex_morph, String
    field :sex_gen, String
    field :sex_consensus, String
    field :age_as_reported, String
    field :age_class, String
    field :height, Float
    field :pathologies_type, String
    field :skeleton_id, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
