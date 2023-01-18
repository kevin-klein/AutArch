# frozen_string_literal: true

module Types
  class ChronologyType < Types::BaseObject
    field :id, ID, null: false
    field :context_from, Integer
    field :context_to, Integer
    field :skeleton_id, Integer
    field :grave_id, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :period_id, Integer

    field :period, PeriodType
    field :c14dates, [C14DateType]
  end
end
