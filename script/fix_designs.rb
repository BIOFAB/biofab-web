#!script/rails runner



max_performance = 0
Design.all.each do |design|
  if design.performance > max_performance
    max_performance = design.performance
  end

end


Design.all.each do |design|
  design.performance_normalized = design.performance / max_performance
  design.performance_sd_normalized = design.performance_sd / max_performance
  design.reliability = 7
  design.save!
end
