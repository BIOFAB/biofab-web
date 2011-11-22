class ProjectSelfReference < ActiveRecord::Migration
  def up
    add_column :projects, :parent_project_id, :integer
  end

  def down
  end
end
