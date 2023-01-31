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
#  ref_14c           :string           is an Array
#  chronology_id     :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  bone_id           :bigint
#
require 'test_helper'

class C14DateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
