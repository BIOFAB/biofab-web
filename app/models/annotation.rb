class Annotation < ActiveRecord::Base
  belongs_to :part
  belongs_to :parent_part, :class_name => 'Part'
  belongs_to :annotation_type

  # retrieve the annotation sequence from the part sequence
  def sequence
    part.sequence[from..to]
  end
end
