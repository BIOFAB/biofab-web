class RenameFeatureType < ActiveRecord::Migration
  def up
    rename_column :features, :type, :type_name
  end

  def down
    rename_column :features, :type_name, :type
  end
end
