class BcDesignsAddPerformanceSd < ActiveRecord::Migration
  def up
    add_column :bc_designs, :performance_sd, :float
  end

  def down
  end
end
