class CreateStrains < ActiveRecord::Migration
  def change
    create_table :strains do |t|
      t.string :biofab_id
      t.integer :organism_id
      t.integer :backbone_id
      t.integer :plasmid_id
      t.integer :eou_id
      t.string :location

      t.timestamps
    end
  end
end
