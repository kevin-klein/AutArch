# frozen_string_literal: true

module Types
  class GraveInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :figure_id, Integer, required: false
    argument :site_id, Integer, required: false
    argument :created_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :updated_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :arc_length, Float, required: false
    argument :area, Float, required: false
    argument :kurgan_id, Integer, required: false
  end
end
