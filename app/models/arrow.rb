# == Schema Information
#
# Table name: arrows
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  angle      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Arrow < ApplicationRecord
  belongs_to :grave
  belongs_to :figure

  def up?
    figure.width < figure.height
  end

  def left_right?
    !up?
  end
end
