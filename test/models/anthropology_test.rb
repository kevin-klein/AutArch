# == Schema Information
#
# Table name: anthropologies
#
#  id               :bigint           not null, primary key
#  sex_morph        :integer
#  sex_gen          :integer
#  sex_consensus    :integer
#  age_as_reported  :string
#  age_class        :integer
#  height           :float
#  pathologies_type :string
#  skeleton_id      :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class AnthropologyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
