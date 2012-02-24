class Design < ActiveRecord::Base

  belongs_to :promoter, :class_name => 'Part', :foreign_key => 'promoter_part_id'
  belongs_to :fpu, :class_name => 'Part', :foreign_key => 'fpu_part_id'
  belongs_to :plasmid, :class_name => 'Part', :foreign_key => 'plasmid_part_id'

  # return all designs within a range of performance
  def self.in_performance_range(min, max, limit)
    self.where(["(performance - performance_sd) > ? AND (performance + performance_sd) < ?", min, max]).includes({:promoter => {:annotations => :annotation_type}, :fpu => {:annotations => :annotation_type}}).limit(limit)
  end

  

end
