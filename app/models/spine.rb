# == Schema Information
#
# Table name: figures
#
#  id                   :bigint           not null, primary key
#  page_id              :bigint           not null
#  x1                   :integer          not null
#  x2                   :integer          not null
#  y1                   :integer          not null
#  y2                   :integer          not null
#  type                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  area                 :float
#  perimeter            :float
#  meter_ratio          :float
#  angle                :float
#  parent_id            :integer
#  identifier           :string
#  width                :float
#  height               :float
#  text                 :string
#  site_id              :bigint
#  validated            :boolean          default(FALSE), not null
#  verified             :boolean          default(FALSE), not null
#  disturbed            :boolean          default(FALSE), not null
#  contour              :text             default([]), not null
#  deposition_type      :integer          default(0), not null
#  publication_id       :integer
#  percentage_scale     :integer
#  page_size            :integer
#  manual_bounding_box  :boolean          default(FALSE)
#  bounding_box_angle   :integer
#  bounding_box_height  :float
#  bounding_box_width   :float
#  control_point_1_x    :integer
#  control_point_1_y    :integer
#  control_point_2_x    :integer
#  control_point_2_y    :integer
#  control_point_3_x    :integer
#  control_point_3_y    :integer
#  control_point_4_x    :integer
#  control_point_4_y    :integer
#  anchor_point_1_x     :integer
#  anchor_point_1_y     :integer
#  anchor_point_2_x     :integer
#  anchor_point_2_y     :integer
#  anchor_point_3_x     :integer
#  anchor_point_3_y     :integer
#  anchor_point_4_x     :integer
#  anchor_point_4_y     :integer
#  probability          :float
#  contour_info         :jsonb
#  real_world_area      :float
#  real_world_width     :float
#  real_world_height    :float
#  real_world_perimeter :float
#
class Spine < Figure
  belongs_to :grave, foreign_key: "parent_id", optional: true, inverse_of: :spines

  def angle
    y_axis = Vector[0, 1]
    figure_vector = Vector[(x2 - x1).abs, (y1 - y2).abs].normalize

    # 57.29578 = 1 radians
    figure_vector.angle_with(y_axis) * 57.29578
  end

  def angle_with_arrow(arrow) # rubocop:disable Metrics/AbcSize
    angle = -arrow.angle % 360

    # simplified rotation matrix for [0, -1] (y axis for images, grows downwards)
    # becaue y axis points downwards, arrow has to point at -1
    angle = (angle * Math::PI) / 180
    x1 = -Math.sin(angle)
    y1 = -Math.cos(angle)
    angle = Math.atan2(vector.normalize[1], vector.normalize[0]) - Math.atan2(y1, x1)
    angle = angle * 180 / Math::PI
    angle += 360 if angle.negative?
    angle
  end
end
