class CreateCharacterizations < ActiveRecord::Migration
  def change
    create_table :characterizations do |t|
      t.integer :replicate_id
      t.integer :characterization_type_id
      t.string :file_path
      t.string :description

      t.timestamps
    end
  end
end
