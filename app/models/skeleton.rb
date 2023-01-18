# == Schema Information
#
# Table name: skeletons
#
#  id          :bigint           not null, primary key
#  grave_id    :bigint           not null
#  figure_id   :integer          not null
#  angle       :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  skeleton_id :string
#
class Skeleton < ApplicationRecord
  belongs_to :grave
  belongs_to :figure
  has_one :skull, dependent: :destroy

  has_one :chronology
  has_one :taxonomy
  has_one :anthropology
  has_one :spine

  has_many :stable_isotopes
  has_many :genetics

  accepts_nested_attributes_for :chronology
  accepts_nested_attributes_for :taxonomy
end
