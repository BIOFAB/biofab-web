class RandomizedBd < ActiveRecord::Base

  belongs_to :plasmid, :class_name => 'Part', :foreign_key => 'plasmid_part_id'
  belongs_to :fpu, :class_name => 'Part', :foreign_key => 'part_id'

end
