class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :part_id
      t.integer :start
      t.integer :end
      t.integer :annotation_type_id

      t.timestamps
    end
  end
end
