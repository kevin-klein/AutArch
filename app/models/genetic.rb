# == Schema Information
#
# Table name: genetics
#
#  id               :bigint           not null, primary key
#  data_type        :integer
#  endo_content     :float
#  ref_gen          :string
#  skeleton_id      :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  mt_haplogroup_id :bigint
#  y_haplogroup_id  :bigint
#  bone_id          :bigint
#
class Genetic < ApplicationRecord
  belongs_to :skeleton
  belongs_to :mt_haplogroup, optional: true
  belongs_to :y_haplogroup, optional: true
  belongs_to :bone, optional: true

  enum data_type: {
    k1240: 1,
    mt: 2,
    shotgun: 3,
    screened: 4
  }
end
