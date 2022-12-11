# == Schema Information
#
# Table name: skeletons
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  angle      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Skeleton < ApplicationRecord
  belongs_to :grave
  belongs_to :figure
  has_one :skull, dependent: :destroy
end
