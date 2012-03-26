class BcDesign < ActiveRecord::Base

  belongs_to :plasmid, :class_name => 'Part', :foreign_key => 'plasmid_part_id'

  

end
