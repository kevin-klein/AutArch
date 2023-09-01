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
class Good < Figure
  belongs_to :grave, foreign_key: 'parent_id', optional: true

  def relative_center_to_grave
    x1 = (x1 - grave.x1).abs
    x2 = (x1 - grave.x2).abs

    y1 = (y1 - grave.y1).abs
    y2 = (y2 - grave.y2).abs

    [(x1 + x2) / 2, (y1 + y2) / 2]
  end

  def percentage_position
    x, y = relative_center_to_grave

    return [] if grave.meter_pixel.nil?

    x /= grave.meter_pixel
    y /= grave.meter_pixel

    grave_width, grave_height = grave.width_height

    if grave.upwards?
      [y / grave_height, x / grave_width]
    else
      [x / grave_width, y / grave_height]
    end
  end
end
