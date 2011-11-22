class PlateWell < ActiveRecord::Base
  belongs_to :plate
  belongs_to :replicate
  has_and_belongs_to_many :files, :class_name => 'DataFile'

  def self.well_name_to_row_col(well_name)
    row_name = well_name[0..0].upcase
    col_name = well_name[1..2]

    row = row_name[0] - ?A + 1
    col = col_name.to_i
    return [row, col]
  end

  def file_by_type(type_name)
    files.where(["type_name = ?", type_name]).first
  end

end
