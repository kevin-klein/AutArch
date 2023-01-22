# frozen_string_literal: true

module Types
  class TaxonomyInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :culture_note, String, required: false
    argument :culture_reference, String, required: false
    argument :culture_id, ID, required: false
  end
end
