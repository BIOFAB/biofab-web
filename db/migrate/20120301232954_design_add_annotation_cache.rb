class DesignAddAnnotationCache < ActiveRecord::Migration
  def up
    add_column :designs, :promoter_annotations, :text
    add_column :designs, :fpu_annotations, :text
  end

  def down
  end
end
