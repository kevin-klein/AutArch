# frozen_string_literal: true

module Types
  class SkeletonFigureInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :figure_id, Integer, required: false
    argument :grave_id, Integer, required: false
    argument :skeleton_id, Integer, required: false
  end
end
