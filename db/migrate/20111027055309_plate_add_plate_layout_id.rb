class PlateAddPlateLayoutId < ActiveRecord::Migration
  def up
    add_column :plates, :plate_layout_id, :integer
  end

  def down
  end
end
