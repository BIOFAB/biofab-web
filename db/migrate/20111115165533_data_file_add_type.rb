class DataFileAddType < ActiveRecord::Migration
  def up
    add_column :data_files, :type, :string
  end

  def down
  end
end
