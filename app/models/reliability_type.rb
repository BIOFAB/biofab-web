class ReliabilityType < ActiveRecord::Base

  has_many :reliabilities, :foreign_key => :type_id

end
