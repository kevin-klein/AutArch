class CrossSectionArrow < ApplicationRecord
  belongs_to :figure
  belongs_to :grave

  def length
    figure.y2 - figure.y1
  end
end
