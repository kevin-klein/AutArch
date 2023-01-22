# frozen_string_literal: true

module Types
  class PublicationType < Types::BaseObject
    field :id, ID, null: false
    field :author, String
    field :title, String
  end
end
