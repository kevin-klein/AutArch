# == Schema Information
#
# Table name: chronologies
#
#  id           :integer          not null, primary key
#  context_from :integer
#  context_to   :integer
#  skeleton_id  :integer
#  grave_id     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  period_id    :integer
#
class Chronology < ApplicationRecord
  belongs_to :grave, optional: true
  belongs_to :skeleton
  belongs_to :period, optional: true

  has_many :c14_dates

  accepts_nested_attributes_for :c14_dates
end
