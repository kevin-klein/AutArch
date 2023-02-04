class AddYearToPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :publications, :year, :string
  end
end
