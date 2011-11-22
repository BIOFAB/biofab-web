class CreatePlateLayoutWells < ActiveRecord::Migration
  def change
    create_table :plate_layout_wells do |t|
      t.integer :plate_layout_id
      t.integer :row
      t.integer :column
      t.integer :eou_id
      t.integer :organism_id

      t.timestamps
    end
  end
end
