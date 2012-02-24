class CreateDesigns < ActiveRecord::Migration
  def change
    create_table :designs do |t|
      t.string :promoter_biofab_id
      t.string :promoter_name
      t.text :promoter_sequence
      t.string :fpu_biofab_id
      t.text :fpu_sequence
      t.text :promoter_upstream_sequence
      t.text :fpu_downstream_sequence
      t.text :plasmid_sequence
      t.string :reporter_gene
      t.string :plasmid_biofab_id
      t.string :plasmid_biofab_id
      t.string :antibiotic_marker
      t.string :strain_biofab_id
      t.float :performance
      t.float :performance_sd

      t.timestamps
    end
  end
end
