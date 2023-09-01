# == Schema Information
#
# Table name: figures
#
#  id                    :integer          not null, primary key
#  page_id               :integer          not null
#  x1                    :integer          not null
#  x2                    :integer          not null
#  y1                    :integer          not null
#  y2                    :integer          not null
#  type                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  area                  :float
#  perimeter             :float
#  meter_ratio           :float
#  angle                 :float
#  parent_id             :integer
#  identifier            :string
#  width                 :float
#  height                :float
#  text                  :string
#  site_id               :integer
#  validated             :boolean          default(FALSE), not null
#  verified              :boolean          default(FALSE), not null
#  disturbed             :boolean          default(FALSE), not null
#  contour               :text             default([]), not null
#  deposition_type       :integer          default(0), not null
#  publication_id        :string
#  percentage_scale      :integer
#  page_size             :integer
#  manual_bounding_box   :boolean          default(FALSE)
#  bounding_box_center_x :integer
#  bounding_box_center_y :integer
#  bounding_box_angle    :integer
#  bounding_box_width    :integer
#  bounding_box_height   :integer
#
class Artefact < Figure
end
