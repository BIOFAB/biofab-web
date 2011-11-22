class FixHasAndBelongsToManyAssociations < ActiveRecord::Migration
  def up
#    remove_table :feature_sets_features
#    create_table :feature_sets_features, :id => false do |t|
#      t.integer :feature_id
#      t.integer :feature_set_id
#    end

#    remove_table :performances_characterizations
#    create_table :performances_characterizations, :id => false do |t|
#      t.integer :performance_id
#      t.integer :characterization_id
#    end

    remove_column :feature_sets_features, :id
    remove_column :performances_characterizations, :id

  end

  def down
    add_column :feature_sets_features, :id, :primary_key
    add_column :performances_characterizations, :id, :primary_key
  end
end
