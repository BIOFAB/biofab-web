class DesignAddFpuName < ActiveRecord::Migration
  def up
    add_column :designs, :fpu_name, :string
  end

  def down
  end
end
