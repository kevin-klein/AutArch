# == Schema Information
#
# Table name: skulls
#
#  id          :bigint           not null, primary key
#  skeleton_id :bigint           not null
#  figure_id   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Skull < ApplicationRecord
  belongs_to :skeleton
  belongs_to :figure
end
