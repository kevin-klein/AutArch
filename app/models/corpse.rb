class Corpse < ApplicationRecord
  belongs_to :grave
  belongs_to :figure
end
