# frozen_string_literal: true

module Types
  class C14DateType < Types::BaseObject
    field :id, ID, null: false
    field :c14_type, String, null: false
    field :lab_id, String
    field :age_bp, Integer, null: false
    field :interval, Integer, null: false
    field :material, String
    field :calbc_1_sigma_max, Float
    field :calbc_1_sigma_min, Float
    field :calbc_2_sigma_max, Float
    field :calbc_2_sigma_min, Float
    field :date_note, String
    field :cal_method, String
    field :ref_14c, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :bone, BoneType
  end
end
