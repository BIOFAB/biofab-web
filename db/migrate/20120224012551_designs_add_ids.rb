class DesignsAddIds < ActiveRecord::Migration
  def up
    add_column :designs, :promoter_part_id, :integer
    add_column :designs, :fpu_part_id, :integer
    add_column :designs, :plasmid_part_id, :integer
    add_column :designs, :strain_part_id, :integer
  end

  def down
  end
end
