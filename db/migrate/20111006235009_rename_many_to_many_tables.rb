class RenameManyToManyTables < ActiveRecord::Migration
  def up
    rename_table :feature_set_features, :feature_sets_features
    rename_table :performance_characterizations, :performances_characterizations
  end

  def down
    rename_table :feature_sets_features, :feature_set_features
    rename_table :performances_characterizations, :performance_characterizations
  end
end
