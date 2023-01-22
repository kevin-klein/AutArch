# frozen_string_literal: true

module Types
  class SiteInputType < Types::BaseInputObject
    argument :id, ID, required: true
    argument :lat, Float, required: false
    argument :lon, Float, required: false
    argument :name, String, required: false
    argument :locality, String, required: false
    argument :country_code, Integer, required: false
    argument :site_code, String, required: false
  end
end
