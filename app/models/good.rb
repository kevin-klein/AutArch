# == Schema Information
#
# Table name: goods
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  type       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Good < ApplicationRecord
  belongs_to :grave
  belongs_to :figure

  def relative_center_to_grave
    x1 = (figure.x1 - grave.figure.x1).abs
    x2 = (figure.x1 - grave.figure.x2).abs

    y1 = (figure.y1 - grave.figure.y1).abs
    y2 = (figure.y2 - grave.figure.y2).abs

    [(x1 + x2) / 2, (y1 + y2) / 2]
  end

  def percentage_position
    x, y = relative_center_to_grave

    return [] if grave.meter_pixel.nil?

    x = x / grave.meter_pixel
    y = y / grave.meter_pixel

    grave_width, grave_height = grave.width_height

    if grave.upwards?
      [y / grave_height, x / grave_width]
    else
      [x / grave_width, y / grave_height]
    end
  end
end
