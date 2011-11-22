class PlateLayoutChannel < ActiveRecord::Migration
  def up
    add_column :plate_layouts, :channel, :string
  end

  def down
  end
end
