class Annotation < ActiveRecord::Base
  belongs_to :part
  belongs_to :parent_part, :class_name => 'Part'
  belongs_to :annotation_type
end
