# frozen_string_literal: true

module Types
  class PageType < Types::BaseObject
    field :id, ID, null: false
    field :publication_id, ID, null: false
    field :number, Integer
    field :image_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :image, ImageType
  end
end
