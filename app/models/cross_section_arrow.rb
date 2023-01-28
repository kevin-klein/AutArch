# == Schema Information
#
# Table name: cross_section_arrows
#
#  id         :bigint           not null, primary key
#  figure_id  :bigint           not null
#  grave_id   :bigint           not null
#  length     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CrossSectionArrow < Figure
  belongs_to :grave, foreign_key: 'parent_id', optional: true

  def length
    y2 - y1
  end
end
