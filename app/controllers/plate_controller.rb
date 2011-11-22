class PlateController < ApplicationController

  def show
    @plate = Plate.includes(:wells => {:replicate => :characterizations}).find(params['id'])
  end

  def characterization_xls
    plate = Plate.find(params['id'])
    path = plate.get_characterization_xls
    send_file(path, :type => "application/vnd.ms-excel")
  end

  def performance_xls
    plate = Plate.find(params['id'])
    path = plate.get_performance_xls
    send_file(path, :type => "application/vnd.ms-excel")
  end


end
