class RemoveBackbonesTable < ActiveRecord::Migration
  def up
#    drop_table :backbones
    remove_column :plasmids, :backbone_id
    remove_column :strains, :backbone_id
  end

  def down
  end
end
