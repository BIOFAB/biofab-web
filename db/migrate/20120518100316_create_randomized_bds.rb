class CreateRandomizedBds < ActiveRecord::Migration
  def change
    create_table :randomized_bds do |t|
      t.string :biofab_id
      t.text :sequence
      t.text :plasmid_sequence
      t.string :plasmid_biofab_id
      t.string :strain_biofab_id
      t.string :strain
      t.string :antibiotic_marker
      t.string :ori
      t.float :fcs
      t.float :fcs_sd
      t.float :fcs_normalized
      t.float :fcs_sd_normalized

      t.timestamps
    end
  end
end
