# == Schema Information
#
# Table name: pattern_parts
#
#  id          :bigint           not null, primary key
#  figure_id   :bigint           not null
#  x1          :integer          not null
#  y1          :integer          not null
#  x2          :integer          not null
#  y2          :integer          not null
#  description :text
#  confidence  :float            default(1.0)
#  feature_type: integer         default(0)
#  features    :jsonb            default({})
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PatternPart < ApplicationRecord
  belongs_to :figure

  validates :x1, :y1, :x2, :y2, presence: true
  validate :bounding_box_valid

  enum :feature_type, {
    texture: 0,
    color: 1,
    edge: 2
  }

  def width
    x2 - x1
  end

  def height
    y2 - y1
  end

  def area
    width * height
  end

  def center
    {
      x: (x1 + x2) / 2.0,
      y: (y1 + y2) / 2.0
    }
  end

  def bounding_box_valid
    if x1 >= x2 || y1 >= y2
      errors.add(:base, "Invalid bounding box: x1 must be less than x2 and y1 must be less than y2")
    end
  end

  def to_json
    {
      id: id,
      figure_id: figure_id,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      width: width,
      height: height,
      description: description,
      confidence: confidence,
      feature_type: feature_type,
      features: features
    }.to_json
  end
end
