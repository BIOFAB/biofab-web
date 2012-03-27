#!script/rails runner

perfs = PartPerformance.all

max = perfs.collect(&:goi_sd).compact.max

puts "== Calculating FPU reliabilities =="

perfs.each do |perf|
  next if pref.goi_sd.blank?
  perf.reliability = 10 - ((perf.goi_sd / max) * 10)
  puts "#{perf.part_id} - #{perf.reliability}"
  perf.save!
end

