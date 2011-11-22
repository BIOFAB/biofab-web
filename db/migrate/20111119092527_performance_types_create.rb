
class PerformanceTypesCreate < ActiveRecord::Migration
  def up
    
    perf_type = PerformanceType.new
    perf_type.name = 'mean_of_means'
    perf_type.save!   

    perf_type = PerformanceType.new
    perf_type.name = 'variance_of_means'
    perf_type.save!   

    perf_type = PerformanceType.new
    perf_type.name = 'standard_deviation_of_means'
    perf_type.save!   

    perf_type = PerformanceType.new
    perf_type.name = 'mean_of_standard_deviation'
    perf_type.save!   

    perf_type = PerformanceType.new
    perf_type.name = 'mean_of_variance'
    perf_type.save!   


  end

  def down
  end
end
