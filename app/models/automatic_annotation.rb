class AutomaticAnnotation < ActiveRecord::Base

  belongs_to :collection
  belongs_to :part_type
  belongs_to :annotate_with_part_type, :class_name => 'PartType'

end
