#!script/rails runner

perfs = PartPerformance.all

max = perfs.collect(&:goi_sd).max

puts "== Calculating FPU reliabilities =="

perfs.each do |perf|
  perf.reliability = (perf.goi_sd / max) * 10
  puts "#{perf.part_id} - #{perf.reliability}"
  perf.save!
end

