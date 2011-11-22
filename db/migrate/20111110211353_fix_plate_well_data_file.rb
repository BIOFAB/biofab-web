class FixPlateWellDataFile < ActiveRecord::Migration
  def up
    rename_column :plate_well_data_files, :file_id, :data_file_id
  end

  def down
  end
end
