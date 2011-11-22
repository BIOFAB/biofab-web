class CreateSequencings < ActiveRecord::Migration
  def change
    create_table :sequencings do |t|
      t.integer :forward_primer_id
      t.integer :reverse_primer_id
      t.string :expected_sequence
      t.string :abi_file_path

      t.timestamps
    end
  end
end
