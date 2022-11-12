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
