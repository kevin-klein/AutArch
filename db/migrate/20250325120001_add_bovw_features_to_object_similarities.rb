class AddBovwFeaturesToObjectSimilarities < ActiveRecord::Migration[7.0]
  def change
    add_column :object_similarities, :bovw_features, :jsonb, array: true, default: [], null: false
  end
end