class ReplicateAddName < ActiveRecord::Migration
  def up
    add_column :replicates, :name, :string
  end

  def down
  end
end
