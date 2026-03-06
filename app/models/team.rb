class Team < ApplicationRecord
  has_many :user_teams, dependent: :destroy
  has_many :users, through: :user_teams

  has_many :publication_teams, dependent: :destroy
  has_many :publications, through: :publication_teams

  validates :name, presence: true, uniqueness: true
end
