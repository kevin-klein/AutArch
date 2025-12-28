class KeyPoint < ApplicationRecord
  belongs_to :figure

  enum :label, Vision::CenterNet::PoseModel::KEYPOINT_NAMES.map.with_index { |x, i| [x.to_sym, i] }.to_h
end
