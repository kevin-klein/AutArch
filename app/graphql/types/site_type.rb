# frozen_string_literal: true

module Types
  class SiteType < Types::BaseObject
    field :id, ID, null: false
    field :lat, Float
    field :lon, Float
    field :name, String
    field :locality, String
    field :country_code, Integer
    field :site_code, String
    field :graves, [Types::GraveType]
  end
end
