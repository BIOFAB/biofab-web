class DesignsNormalizedValues < ActiveRecord::Migration
  def up
    add_column :designs, :performance_normalized, :float
    add_column :designs, :performance_sd_normalized, :float
    add_column :designs, :reliability, :float
  end

  def down
  end
end
