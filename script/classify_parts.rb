#!script/rails runner

# This script assigns parts to projects based on descriptions
# This is useful for the parts that have been imported from google docs


modular = Project.find_by_name("Modular Promoter Library")
random = Project.find_by_name("Random Promoter Library")

modular_length = modular.parts.length
random_length = random.parts.length

if !modular || !random
  raise "Could not find modular and/or random promoter library"
end

puts "Classifying promoters:"

Part.all.each do |part|
  next if part.description.blank?
  part_desc = part.description.strip.downcase

  if part_desc == 'synthetic modular promoter'
    part.project = modular
    part.save!
    print '|'
  elsif part_desc == 'synthetic randomized promoter'
    part.project = random
    part.save!
    print '|'
  else
    print '.'
  end

  STDOUT.flush
  $stdout.flush

end

puts "Classification completed!"

puts "Modular now has #{modular.parts.length} parts"
puts "Random now has #{random.parts.length} parts"

