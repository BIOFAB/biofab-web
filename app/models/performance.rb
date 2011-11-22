class Performance < ActiveRecord::Base

  belongs_to :strain
  belongs_to :performance_type
  has_and_belongs_to_many :characterizations
  has_and_belongs_to_many :reliabilities


end
