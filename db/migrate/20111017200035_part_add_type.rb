class PartAddType < ActiveRecord::Migration
  def up
    add_column :parts, :part_type, :integer
  end

  def down
  end
end
