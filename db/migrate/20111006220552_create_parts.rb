class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :biofab_id
      t.string :sequence
      t.string :description
      t.string :location

      t.timestamps
    end
  end
end
