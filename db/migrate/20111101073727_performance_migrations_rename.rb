class PerformanceMigrationsRename < ActiveRecord::Migration
  def up
    rename_table :performances_characterizations, :characterizations_performances
  end

  def down
  end
end
