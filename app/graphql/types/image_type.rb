# frozen_string_literal: true

module Types
  class ImageType < Types::BaseObject
    field :id, ID, null: false
    field :data, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :width, Integer
    field :height, Integer

    def data
      "data:image/jpeg;base64,#{Base64.encode64 object.data}"
    end
  end
end
