# frozen_string_literal: true

module Types
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    field :lat, Float
    field :lon, Float
    field :name, String
    field :site_code, String
    field :locality, String
    field :country_code, String
  end
end
