class PlateLayoutWell < ActiveRecord::Base
  belongs_to :eou
  belongs_to :organism
  belongs_to :plate_layout


  # returns a name like C03
  def name
    return nil if (column <= 0) || (row <= 0)
    row_name = (?A..?Z).to_a[row-1].chr
    col_name = (column < 10) ? '0'+column.to_s : column.to_s
    return row_name+col_name    
  end

  def descriptor
    "#{(organism) ? organism.substrain : 'ORGANISM_NA'} | #{(eou) ? eou.descriptor : 'EOU_NA'}"
  end

end
