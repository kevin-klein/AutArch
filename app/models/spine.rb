# == Schema Information
#
# Table name: spines
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  figure_id  :bigint
#
class Spine < ApplicationRecord
  belongs_to :line
end
