class DataFileAddSubdir < ActiveRecord::Migration
  def up
    add_column :data_files, :subdir, :string
  end

  def down
  end
end
