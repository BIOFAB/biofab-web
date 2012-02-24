class AnnotationChangeStartEnd < ActiveRecord::Migration
  def up
    rename_column :annotations, :start, :from
    rename_column :annotations, :end, :to
  end

  def down
  end
end
