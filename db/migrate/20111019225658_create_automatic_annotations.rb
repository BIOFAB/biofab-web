class CreateAutomaticAnnotations < ActiveRecord::Migration
  def change
    create_table :automatic_annotations do |t|
      t.integer :part_type_id
      t.integer :collection_id
      t.integer :part_type_id

      t.timestamps
    end
  end
end
