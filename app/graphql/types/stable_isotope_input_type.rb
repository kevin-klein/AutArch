# frozen_string_literal: true

module Types
  class StableIsotopeInputType < Types::BaseInputObject
    argument :iso_id, String, required: false
    argument :iso_value, Float, required: false
    argument :ref_iso, String, required: false
    argument :isotope, String, required: false
    argument :baseline, Integer, required: false
    argument :bone_id, Integer, required: false
  end
end
