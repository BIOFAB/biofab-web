class Measurement < ActiveRecord::Base
  belongs_to :characterization
  belongs_to :measurement_type
end
