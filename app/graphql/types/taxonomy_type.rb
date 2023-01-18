# frozen_string_literal: true

module Types
  class TaxonomyType < Types::BaseObject
    field :id, ID, null: false
    field :skeleton_id, Integer
    field :culture_note, String
    field :culture_reference, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :culture, CultureType
  end
end
