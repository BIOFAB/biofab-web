class AutoAnnotationTweak < ActiveRecord::Migration
  def up
    add_column :automatic_annotations, :annotate_with_part_type_id, :integer
  end

  def down
  end
end
