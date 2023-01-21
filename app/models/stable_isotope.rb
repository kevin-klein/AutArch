# == Schema Information
#
# Table name: stable_isotopes
#
#  id          :bigint           not null, primary key
#  skeleton_id :bigint           not null
#  iso_id      :string
#  iso_value   :float
#  ref_iso     :string
#  isotope     :integer
#  baseline    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bone_id     :bigint
#
class StableIsotope < ApplicationRecord
  belongs_to :skeleton
  belongs_to :bone

  enum isotope: {
    c13: 1,
    n15: 2,
    sr: 3,
    s34: 4
  }
end
