class FeatureAddType < ActiveRecord::Migration
  def up
    add_column :features, :type, :string
  end

  def down
    remove_column :features, :type
  end
end
