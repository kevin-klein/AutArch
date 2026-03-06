class PublicationTeam < ApplicationRecord
  belongs_to :publication
  belongs_to :team
end
