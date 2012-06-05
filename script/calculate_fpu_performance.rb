#!script/rails runner

require 'script/math_stuff.rb'


def find_obj(objs, fpu_part_id)
  objs.each do |obj|
    if obj[:fpu_part_id] == fpu_part_id
      return obj
    end
  end
  return nil
end

puts "Deleting all existing fpu_performances in 10 seconds: "

10.times do |i|
  sleep 1
  print '.'
  $stdout.flush
end
print "\n"

puts "Now deleting."

PartPerformance.delete_all

objs = []

BcDesign.all.each do |design|

  obj = find_obj(objs, design.fpu_part_id)

  if obj
    perf = obj[:perf]
  else
    perf = PartPerformance.new
    perf.part_id = design.fpu_part_id
    perf.name = design.fpu_name
    obj = {
      :fpu_part_id => design.fpu_part_id,
      :perf => perf,
      :values => [],
      :cds_part_ids => []
    }
    objs << obj
  end

  puts "#{design.fpu_name} / #{design.fpu_part_id} - #{design.cds_name} / #{design.cds_part_id}"

  if obj[:cds_part_ids].index(design.cds_part_id)
    raise "same GOI twice: #{design.cds_name} / #{design.cds_part_id} for #{design.fpu_name} / #{design.fpu_part_id}"
  end

  obj[:cds_part_ids] << design.cds_part_id
#  obj[:values] << design.performance
  obj[:values] << Math.log(design.performance) / Math.log(2)

end

objs.each do |obj|
  obj[:perf].goi_average = obj[:values].mean
  obj[:perf].goi_sd = obj[:values].standard_deviation
  puts "name: #{obj[:perf].name}. count: #{obj[:values].length}. value: #{obj[:perf].goi_average}. -- #{obj[:cds_part_ids].inspect}"
  obj[:perf].save!
end

puts
puts "Saved #{objs.length} fpu_performances!"
