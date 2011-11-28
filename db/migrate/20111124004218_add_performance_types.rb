class AddPerformanceTypes < ActiveRecord::Migration
  def up
    ['mean_of_variances', 'total_variance'].each do |name|
      perftype = PerformanceType.new
      perftype.name = name
      perftype.save!
    end
  end

  def down
  end
end
