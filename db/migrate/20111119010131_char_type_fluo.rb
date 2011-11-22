class CharTypeFluo < ActiveRecord::Migration
  def up
    add_column :characterizations, :fluo_channel, :string
  end

  def down
  end
end
