class PlateWellDataFile < ActiveRecord::Base
  belongs_to :plate_well
  belongs_to :data_file
end
