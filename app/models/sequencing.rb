class Sequencing < ActiveRecord::Base
  belongs_to :forward_primer_id, :class_name => 'Part'
  belongs_to :reverse_primer_id, :class_name => 'Part'
  belongs_to :project
end
