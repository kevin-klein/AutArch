# == Schema Information
#
# Table name: bones
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Bone < ApplicationRecord
  validates :name, uniqueness: true, presence: true
end
