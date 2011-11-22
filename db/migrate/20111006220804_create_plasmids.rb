class CreatePlasmids < ActiveRecord::Migration
  def change
    create_table :plasmids do |t|
      t.string :biofab_id
      t.integer :backbone_id
      t.integer :part_id
      t.string :location

      t.timestamps
    end
  end
end
