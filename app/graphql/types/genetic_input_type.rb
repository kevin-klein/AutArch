# frozen_string_literal: true

module Types
  class GeneticInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :data_type, String, required: false
    argument :endo_content, String, required: false
    argument :ref_gen, String, required: false
    argument :mt_haplogroup_id, ID, required: false
    argument :y_haplogroup_id, ID, required: false
    argument :bone_id, ID, required: false
  end
end
