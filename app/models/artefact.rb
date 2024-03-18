# == Schema Information
#
# Table name: figures
#
#  id                  :bigint           not null, primary key
#  page_id             :bigint           not null
#  x1                  :integer          not null
#  x2                  :integer          not null
#  y1                  :integer          not null
#  y2                  :integer          not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  area                :float
#  perimeter           :float
#  meter_ratio         :float
#  angle               :float
#  parent_id           :integer
#  identifier          :string
#  width               :float
#  height              :float
#  text                :string
#  site_id             :bigint
#  validated           :boolean          default(FALSE), not null
#  verified            :boolean          default(FALSE), not null
#  disturbed           :boolean          default(FALSE), not null
#  contour             :text             default([]), not null
#  deposition_type     :integer          default(0), not null
#  publication_id      :integer
#  percentage_scale    :integer
#  page_size           :integer
#  manual_bounding_box :boolean          default(FALSE)
#  bounding_box_angle  :integer
#  control_point_1_x   :integer
#  control_point_1_y   :integer
#  control_point_2_x   :integer
#  control_point_2_y   :integer
#  control_point_3_x   :integer
#  control_point_3_y   :integer
#  control_point_4_x   :integer
#  control_point_4_y   :integer
#  anchor_point_1_x    :integer
#  anchor_point_1_y    :integer
#  anchor_point_2_x    :integer
#  anchor_point_2_y    :integer
#  anchor_point_3_x    :integer
#  anchor_point_3_y    :integer
#  anchor_point_4_x    :integer
#  anchor_point_4_y    :integer
#  probability         :float
#
class Artefact < Figure
end
