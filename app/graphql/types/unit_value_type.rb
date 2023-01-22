# frozen_string_literal: true

module Types
  class UnitValueType < Types::BaseObject
    field :unit, String
    field :value, Float
  end
end
