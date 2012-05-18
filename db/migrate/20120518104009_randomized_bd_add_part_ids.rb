class RandomizedBdAddPartIds < ActiveRecord::Migration
  def up
    add_column :randomized_bds, :part_id, :integer
    add_column :randomized_bds, :plasmid_part_id, :integer
  end

  def down
  end
end
