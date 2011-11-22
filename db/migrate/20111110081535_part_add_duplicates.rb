class PartAddDuplicates < ActiveRecord::Migration
  def up
    add_column :parts, :duplicates, :text
  end

  def down
  end
end
