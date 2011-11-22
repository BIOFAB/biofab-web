class CreateEous < ActiveRecord::Migration
  def change
    create_table :eous do |t|
      t.integer :promoter_id
      t.integer :five_prime_utr_id
      t.integer :gene_id
      t.integer :terminator_id

      t.timestamps
    end
  end
end
