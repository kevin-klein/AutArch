# == Schema Information
#
# Table name: mt_haplogroups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MtHaplogroup < ApplicationRecord
end
