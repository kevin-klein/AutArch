# == Schema Information
#
# Table name: scales
#
#  id          :bigint           not null, primary key
#  figure_id   :integer          not null
#  grave_id    :bigint           not null
#  meter_ratio :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Scale < ApplicationRecord
  belongs_to :figure
  belongs_to :grave
end
