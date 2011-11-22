class CreatePlateWells < ActiveRecord::Migration
  def change
    create_table :plate_wells do |t|
      t.integer :plate_id
      t.integer :replicate_id
      t.string :row
      t.string :column

      t.timestamps
    end
  end
end
