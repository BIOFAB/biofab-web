class EouAddComment < ActiveRecord::Migration
  def up
    add_column :eous, :comment, :string
  end

  def down
  end
end
