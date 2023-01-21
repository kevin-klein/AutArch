# frozen_string_literal: true

module Types
  class C14DateInputType < Types::BaseInputObject
    argument :c14_type, String, required: false
    argument :lab_id, String, required: false
    argument :age_bp, Integer, required: false
    argument :interval, Integer, required: false
    argument :material, String, required: false
    argument :calbc_1_sigma_max, Float, required: false
    argument :calbc_1_sigma_min, Float, required: false
    argument :calbc_2_sigma_max, Float, required: false
    argument :calbc_2_sigma_min, Float, required: false
    argument :date_note, String, required: false
    argument :cal_method, String, required: false
    argument :ref_14c, String, required: false
    argument :bone_id, Integer, required: false
  end
end
