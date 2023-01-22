# frozen_string_literal: true

module Types
  class C14DateInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :c14_type, String, required: false
    argument :lab_id, String, required: false
    argument :age_bp, String, required: false
    argument :interval, String, required: false
    argument :material, String, required: false
    argument :calbc_1_sigma_max, String, required: false
    argument :calbc_1_sigma_min, String, required: false
    argument :calbc_2_sigma_max, String, required: false
    argument :calbc_2_sigma_min, String, required: false
    argument :date_note, String, required: false
    argument :cal_method, String, required: false
    argument :ref_14c, String, required: false
    argument :bone_id, ID, required: false
  end
end
