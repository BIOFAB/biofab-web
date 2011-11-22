class CreateAnnotationTypes < ActiveRecord::Migration
  def change
    create_table :annotation_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
