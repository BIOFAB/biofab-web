class PartTypeIdFix < ActiveRecord::Migration
  def up
    rename_column :parts, :part_type, :part_type_id
  end

  def down
  end
end
