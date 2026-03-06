# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  code_hash  :string
#  name       :string
#  role       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :publications

  has_many :user_teams, dependent: :destroy
  has_many :teams, through: :user_teams

  enum :role, {
    user: 1,
    admin: 2
  }
end
