# == Schema Information
#
# Table name: taxonomies
#
#  id                :bigint           not null, primary key
#  skeleton_id       :bigint
#  culture_note      :string
#  culture_reference :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  culture_id        :bigint
#
class Taxonomy < ApplicationRecord
  belongs_to :skeleton
  belongs_to :culture, optional: true
end
