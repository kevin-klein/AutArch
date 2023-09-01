# == Schema Information
#
# Table name: taxonomies
#
#  id                :integer          not null, primary key
#  skeleton_id       :integer
#  culture_note      :string
#  culture_reference :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  culture_id        :integer
#
class Taxonomy < ApplicationRecord
  belongs_to :skeleton
  belongs_to :culture, optional: true
end
