# == Schema Information
#
# Table name: y_haplogroups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class YHaplogroup < ApplicationRecord
  validates :name, uniqueness: true, presence: true
end
