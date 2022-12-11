# == Schema Information
#
# Table name: grave_cross_sections
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GraveCrossSection < ApplicationRecord
  belongs_to :grave
  belongs_to :figure
end
