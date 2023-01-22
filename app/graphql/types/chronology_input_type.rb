# frozen_string_literal: true

module Types
  class ChronologyInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :context_from, String, required: false
    argument :context_to, String, required: false
    argument :period_id, ID, required: false

    argument :c14_dates, [C14DateInputType], required: false
  end
end
