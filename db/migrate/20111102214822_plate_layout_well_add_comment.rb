class PlateLayoutWellAddComment < ActiveRecord::Migration
  def up
    add_column :plate_layout_wells, :comment, :string
  end

  def down
  end
end
