class AssignUsersToPublications < ActiveRecord::Migration[7.0]
  def change
    add_reference :publications, :user
  end
end
