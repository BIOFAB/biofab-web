class DataFileTypeToTypeName < ActiveRecord::Migration
  def up
    rename_column :data_files, :type, :type_name
  end

  def down
  end
end
