class Reliability < ActiveRecord::Base

  belongs_to :part
  belongs_to :reliability_type, :foreign_key => :type_id
  has_and_belongs_to_many :performances

end
