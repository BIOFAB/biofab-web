class StringsToTextsPart2 < ActiveRecord::Migration
  def up
    change_column :part_types, :description, :text
  end

  def down
  end
end
