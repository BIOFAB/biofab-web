class DataFileFix < ActiveRecord::Migration
  def up
    rename_column :data_files, :filepath, :filename
  end

  def down
  end
end
