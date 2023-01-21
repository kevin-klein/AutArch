# frozen_string_literal: true

module Types
  class GeneticType < Types::BaseObject
    field :id, ID, null: false
    field :data_type, String
    field :endo_content, Float
    field :ref_gen, String
    field :skeleton_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :mt_haplogroup, [MtHaplogroupType]
    field :y_haplogroup, [YHaplogroupType]
    field :mt_haplogroup_id, Integer
    field :y_haplogroup_id, Integer
    field :bone_id, Integer
  end
end
