# == Schema Information
#
# Table name: cultures
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Culture < ApplicationRecord
  validates :name, uniqueness: true, presence: true
end
