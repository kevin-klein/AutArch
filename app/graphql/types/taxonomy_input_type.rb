# frozen_string_literal: true

module Types
  class TaxonomyInputType < Types::BaseInputObject
    argument :culture_note, String, required: false
    argument :culture_reference, String, required: false
    argument :culture_id, String, required: false
  end
end
