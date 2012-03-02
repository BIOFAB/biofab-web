class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_project_id'
  has_many :children, :class_name => 'Project', :foreign_key => 'parent_project_id'
  has_many :parts
  has_many :collections
end


