class RemovePlateWellError < ActiveRecord::Migration
  def up
    remove_column :plate_wells, :error
  end

  def down
  end
end
