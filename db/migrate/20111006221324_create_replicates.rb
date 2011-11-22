class CreateReplicates < ActiveRecord::Migration
  def change
    create_table :replicates do |t|
      t.integer :strain_id
      t.integer :number
      t.string :description

      t.timestamps
    end
  end
end
