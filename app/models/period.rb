# == Schema Information
#
# Table name: periods
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Period < ApplicationRecord
  validates :name, uniqueness: true, presence: true
end
