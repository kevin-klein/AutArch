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
require "test_helper"

class StableIsotopeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
