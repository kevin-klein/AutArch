# == Schema Information
#
# Table name: c14_dates
#
#  id                :bigint           not null, primary key
#  c14_type          :integer          not null
#  lab_id            :string
#  age_bp            :integer
#  interval          :integer
#  material          :integer
#  calbc_1_sigma_max :float
#  calbc_1_sigma_min :float
#  calbc_2_sigma_max :float
#  calbc_2_sigma_min :float
#  date_note         :string
#  cal_method        :integer
#  ref_14c           :string
#  chronology_id     :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  bone_id           :bigint
#
class C14Date < ApplicationRecord
  belongs_to :chronology
  belongs_to :bone, optional: true
  serialize :ref_14c, JSON

  enum c14_type: {
    direct: 1,
    indirect: 2
  }

  enum material: {
    human_bone: 1,
    lpp: 2,
    charcoal: 3,
    animal_bone: 4
  }

  enum cal_method: {
    oxcal_4_2_2: 1,
    int_cal_20: 2
  }
end
