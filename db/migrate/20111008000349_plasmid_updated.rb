class PlasmidUpdated < ActiveRecord::Migration
  def up
    remove_column :plasmids, :biofab_id
    remove_column :plasmids, :location
    add_column :plasmids, :eou_id, :integer
    add_column :plasmids, :eou_insertion_point, :integer
  end

  def down
  end
end
