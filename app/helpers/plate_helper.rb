module PlateHelper

  def col_to_twodigit(col_number)
    (col_number.to_i > 9) ? col_number.to_s : "0#{col_number}"
  end

  def row_to_letter(row_number)
    return '' if (row_number < 1) || (row_number > 26)
    return (row_number + 64).chr
  end

end
