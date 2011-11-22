class PlasmidInfoAddOri < ActiveRecord::Migration
  def up
    add_column :plasmid_infos, :ori, :string
  end

  def down
  end
end
