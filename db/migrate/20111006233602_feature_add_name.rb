class FeatureAddName < ActiveRecord::Migration
  def up
    add_column :features, :name, :string
  end

  def down
    remove_column :features, :name
  end
end
