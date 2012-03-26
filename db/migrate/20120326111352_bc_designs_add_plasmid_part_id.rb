class BcDesignsAddPlasmidPartId < ActiveRecord::Migration
  def up
    add_column :bc_designs, :plasmid_part_id, :integer
  end

  def down
  end
end
