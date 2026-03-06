class CreatePublicationTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :publication_teams do |t|
      t.references :publication, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
