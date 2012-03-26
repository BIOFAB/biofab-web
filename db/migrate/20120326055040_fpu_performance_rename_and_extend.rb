class FpuPerformanceRenameAndExtend < ActiveRecord::Migration
  def up
    rename_table :fpu_performances, :part_performances
    add_column :part_performances, :reliability, :float
    add_column :part_performances, :performance, :float
    add_column :part_performances, :performance_sd, :float
  end

  def down
  end
end
