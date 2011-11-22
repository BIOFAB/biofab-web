class CreatePlateLayouts < ActiveRecord::Migration
  def change
    create_table :plate_layouts do |t|
      t.string :name
      t.boolean :hide_global_wells
      t.integer :eou_id
      t.integer :organism_id
      t.integer :user_id
      t.integer :project_id
      t.timestamps
    end
  end
end
