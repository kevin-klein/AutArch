# == Schema Information
#
# Table name: anthropologies
#
#  id               :bigint           not null, primary key
#  sex_morph        :integer
#  sex_gen          :integer
#  sex_consensus    :integer
#  age_as_reported  :string
#  age_class        :integer
#  height           :float
#  pathologies_type :string
#  skeleton_id      :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  species          :integer
#
class Anthropology < ApplicationRecord
  belongs_to :skeleton

  enum sex_morph: {
    female: 1,
    male: 2,
    unclear: 3,
    no_data: 4
  }, _prefix: true

  enum sex_gen: {
    female: 1,
    male: 2,
    unclear: 3,
    no_data: 4
  }, _prefix: true

  enum sex_consensus: {
    female: 1,
    male: 2,
    unclear: 3,
    no_data: 4
  }, _prefix: true

  enum age_class: {
    neonate: 1,
    child: 2,
    young_adult: 3
  }, _prefix: true
end
