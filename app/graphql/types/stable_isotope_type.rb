# frozen_string_literal: true

module Types
  class StableIsotopeType < Types::BaseObject
    field :id, ID, null: false
    field :skeleton_id, Integer, null: false
    field :iso_id, String
    field :iso_value, Float
    field :ref_iso, String
    field :isotope, Integer
    field :baseline, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :bone_id, Integer
  end
end
