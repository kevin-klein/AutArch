# == Schema Information
#
# Table name: genetics
#
#  id               :bigint           not null, primary key
#  data_type        :integer
#  end_content      :float
#  ref_gen          :string
#  skeleton_id      :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  mt_haplogroup_id :bigint
#  y_haplogroup_id  :bigint
#  bone_id          :bigint
#
require "test_helper"

class GeneticTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
