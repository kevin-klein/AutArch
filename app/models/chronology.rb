# == Schema Information
#
# Table name: chronologies
#
#  id           :bigint           not null, primary key
#  context_from :integer
#  context_to   :integer
#  skeleton_id  :bigint
#  grave_id     :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  period_id    :bigint
#
class Chronology < ApplicationRecord
  belongs_to :grave
  belongs_to :skeleton
  belongs_to :period

  has_many :c14_dates
end
