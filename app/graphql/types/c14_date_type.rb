# frozen_string_literal: true

module Types
  class C14DateType < Types::BaseObject
    field :id, ID, null: false
    field :c14_type, String
    field :lab_id, String
    field :age_bp, Integer
    field :interval, Integer
    field :material, String
    field :calbc_1_sigma_max, Float
    field :calbc_1_sigma_min, Float
    field :calbc_2_sigma_max, Float
    field :calbc_2_sigma_min, Float
    field :date_note, String
    field :cal_method, String
    field :ref_14c, String
    def ref_14c
      object.ref_14c.join(', ')
    end
    field :bone, BoneType
    field :bone_id, Integer
  end
end
