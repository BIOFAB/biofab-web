class CreateBcDesigns < ActiveRecord::Migration
  def change
    create_table :bc_designs do |t|
      t.string :fpu_biofab_id
      t.string :fpu_name
      t.text :fpu_sequence
      t.string :cds_biofab_id
      t.string :cds_name
      t.text :cds_sequence
      t.string :plasmid_sequence
      t.string :plasmid_biofab_id
      t.string :strain_biofab_id
      t.string :organism_name
      t.float :fc_average
      t.float :fc_sd
      t.float :performance
      t.integer :fpu_part_id
      t.integer :cds_part_id

      t.timestamps
    end
  end
end
