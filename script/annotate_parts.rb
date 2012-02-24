#!script/rails runner

#puts "this is likely not what you want"
#exit

puts "faking up some nice annotations for your designs"

annots = Annotation.find([1, 2, 3])

count = 0
Design.all.each do |design|

  promoter = design.promoter
  fpu = design.fpu
  promoter.annotations.delete_all
  fpu.annotations.delete_all
  puts "promoter id: #{promoter.id}"

  puts "Doing stuff for Design #{design.id}"
  annots.each do |annot|
    puts "adding annotation: #{annot.id}"
    promoter.annotations << Annotation.new(annot.attributes)
    fpu.annotations << Annotation.new(annot.attributes)
  end
  promoter.save!
  fpu.save!
  puts "promoter has #{promoter.annotations.length} annotations"
  count += 1
end

puts "done with the magnificent fakery"
