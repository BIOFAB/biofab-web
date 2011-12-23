class PlateWellError < ActiveRecord::Migration
  def up
    add_column :plate_wells, :error, :string
  end

  def down
  end
end
