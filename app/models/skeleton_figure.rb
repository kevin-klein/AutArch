class SkeletonFigure < ApplicationRecord
  belongs_to :skeleton
  belongs_to :figure
  belongs_to :grave
end
