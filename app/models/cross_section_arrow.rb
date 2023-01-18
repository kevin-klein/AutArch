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
class CrossSectionArrow < ApplicationRecord
  belongs_to :figure
  belongs_to :grave

  def length
    figure.y2 - figure.y1
  end
end
