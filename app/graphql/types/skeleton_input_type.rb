# frozen_string_literal: true

module Types
  class SkeletonInputType < Types::BaseInputObject
    argument :skeleton_id, String, required: false

    argument :chronology, ChronologyInputType, required: true
    argument :anthropology, AnthropologyInputType, required: true
    argument :taxonomy, TaxonomyInputType, required: true
    argument :stable_isotopes, [StableIsotopeInputType], required: false
    argument :genetics, [GeneticInputType], required: false
  end
end
