# frozen_string_literal: true

module Types
  class PublicationType < Types::BaseObject
    field :id, ID, null: false
    field :author, String
    field :title, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :year, String
    field :user_id, Integer
    field :public, Boolean, null: false

    field :ceramics, [Types::CeramicType]
  end
end
