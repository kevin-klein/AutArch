# frozen_string_literal: true

module Types
  class StableIsotopeInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :iso_id, String, required: false
    argument :iso_value, String, required: false
    argument :ref_iso, String, required: false
    argument :isotope, String, required: false
    argument :baseline, String, required: false
    argument :bone_id, ID, required: false
  end
end
