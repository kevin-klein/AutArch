# == Schema Information
#
# Table name: kurgans
#
#  id             :bigint           not null, primary key
#  width          :integer
#  height         :integer
#  name           :string           not null
#  publication_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Kurgan < Figure
end
