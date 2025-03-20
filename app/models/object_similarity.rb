# == Schema Information
#
# Table name: object_similarities
#
#  id         :bigint           not null, primary key
#  type       :string
#  similarity :float
#  first_id   :bigint           not null
#  second_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ObjectSimilarity < ApplicationRecord
  belongs_to :first, class_name: "Figure"
  belongs_to :second, class_name: "Figure"
end
