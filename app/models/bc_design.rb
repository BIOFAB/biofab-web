class BcDesign < ActiveRecord::Base

  belongs_to :plasmid, :class_name => 'Part', :foreign_key => 'plasmid_part_id'
  belongs_to :fpu, :class_name => 'Part', :foreign_key => 'fpu_part_id'
  belongs_to :cds, :class_name => 'Part', :foreign_key => 'cds_part_id'

  

end
