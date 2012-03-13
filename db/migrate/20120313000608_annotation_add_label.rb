class AnnotationAddLabel < ActiveRecord::Migration
  def up
    add_column :annotations, :label, :string
  end

  def down
  end
end
