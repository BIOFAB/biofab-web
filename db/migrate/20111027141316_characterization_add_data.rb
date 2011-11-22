class CharacterizationAddData < ActiveRecord::Migration
  def up
    add_column :characterizations, :value, :float
    add_column :characterizations, :standard_deviation, :float
  end

  def down
  end
end
