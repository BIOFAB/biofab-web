class Annotation < ActiveRecord::Base
  belongs_to :parent_part, :class_name => 'Part' # this is an annotation of a subsequence of this part
  belongs_to :part # the part contained in the annotation
  belongs_to :annotation_type

  attr_accessor :offset

  # retrieve the annotation sequence from the part sequence
  def sequence
    parent_part.sequence[from..to]
  end

  def from_offset
    from + offset
  end

  def to_offset
    to + offset
  end
end
