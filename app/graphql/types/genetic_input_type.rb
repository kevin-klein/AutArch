# frozen_string_literal: true

module Types
  class GeneticInputType < Types::BaseInputObject
    argument :data_type, String, required: false
    argument :endo_content, Float, required: false
    argument :ref_gen, String, required: false
    argument :mt_haplogroup_id, Integer, required: false
    argument :y_haplogroup_id, Integer, required: false
    argument :bone_id, Integer, required: false
  end
end
