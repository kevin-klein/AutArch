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

  has_one :chronology, dependent: :destroy
  has_one :taxonomy, dependent: :destroy
  has_one :anthropology, dependent: :destroy
  has_one :spine, dependent: :destroy

  has_many :stable_isotopes, dependent: :destroy
  has_many :genetics, dependent: :destroy

  accepts_nested_attributes_for :chronology
  accepts_nested_attributes_for :taxonomy
  accepts_nested_attributes_for :anthropology
  accepts_nested_attributes_for :spine
  accepts_nested_attributes_for :stable_isotopes
  accepts_nested_attributes_for :genetics
end
