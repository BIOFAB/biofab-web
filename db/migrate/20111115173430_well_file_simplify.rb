class WellFileSimplify < ActiveRecord::Migration
  def up
    create_table "data_files_plate_wells", :id => false, :force => true do |t|
      t.integer "data_file_id"
      t.integer "plate_well_id"
    end
    
    drop_table :plate_well_data_files

  end

  def down
  end
end
