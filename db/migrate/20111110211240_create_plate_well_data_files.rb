class CreatePlateWellDataFiles < ActiveRecord::Migration
  def change
    create_table :plate_well_data_files do |t|
      t.integer :plate_well_id
      t.integer :file_id
      t.string :type

      t.timestamps
    end
  end
end
