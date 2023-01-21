# frozen_string_literal: true

module Types
  class AnthropologyInputType < Types::BaseInputObject
    argument :sex_morph, String, required: false
    argument :sex_gen, String, required: false
    argument :sex_consensus, String, required: false
    argument :age_as_reported, String, required: false
    argument :age_class, String, required: false
    argument :height, String, required: false
    argument :pathologies_type, String, required: false
  end
end
