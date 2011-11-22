class ProjectStuff < ActiveRecord::Migration
  def up
    create_table :projects_users, :id => false, :force => true do |t|
      t.integer :project_id
      t.integer :user_id
    end

    add_column :parts, :project_id, :integer
    add_column :collections, :project_id, :integer
    add_column :strains, :project_id, :integer
    add_column :sequencings, :project_id, :integer
  end

  def down
  end
end
