# frozen_string_literal: true

module Types
  class GraveType < Types::BaseObject
    field :id, ID, null: false
    field :goods, [GoodType]
    field :page_id, Integer, null: false
    field :width_with_unit, GraphQL::Types::JSON, null: false
    field :height_with_unit, GraphQL::Types::JSON, null: false
    field :area_with_unit, GraphQL::Types::JSON, null: false
    field :x1, Integer, null: false
    field :x2, Integer, null: false
    field :y1, Integer, null: false
    field :y2, Integer, null: false
    field :type, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :area, Float
    field :perimeter, Float
    field :meter_ratio, Float
    field :angle, Float
    field :parent_id, Integer
    field :identifier, String
    field :width, Float
    field :height, Float
    field :text, String
    field :site_id, Integer
    field :validated, Boolean, null: false
    field :verified, Boolean, null: false
    field :disturbed, Boolean, null: false
    field :contour, String, null: false
    field :deposition_type, Integer, null: false
    field :publication_id, Integer
    field :percentage_scale, Integer
    field :page_size, Integer
    field :manual_bounding_box, Boolean
    field :bounding_box_angle, Integer
    field :bounding_box_height, Float
    field :bounding_box_width, Float
    field :control_point_1_x, Integer
    field :control_point_1_y, Integer
    field :control_point_2_x, Integer
    field :control_point_2_y, Integer
    field :control_point_3_x, Integer
    field :control_point_3_y, Integer
    field :control_point_4_x, Integer
    field :control_point_4_y, Integer
    field :anchor_point_1_x, Integer
    field :anchor_point_1_y, Integer
    field :anchor_point_2_x, Integer
    field :anchor_point_2_y, Integer
    field :anchor_point_3_x, Integer
    field :anchor_point_3_y, Integer
    field :anchor_point_4_x, Integer
    field :anchor_point_4_y, Integer
    field :probability, Float
    field :contour_info, GraphQL::Types::JSON
    field :real_world_area, Float
    field :real_world_width, Float
    field :real_world_height, Float
    field :real_world_perimeter, Float
    field :features, Float, null: false
    field :efds, Float, null: false
    field :internment_type, Integer
  end
end
