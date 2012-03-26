#!script/rails runner

designs = Design.all + BcDesign.all

type_name = 'Plasmid'
part_type = PartType.find_by_name(type_name)
if !part_type
  part_type = PartType.new
  part_type.name = type_name
  part_type.save!
end

puts "== Creating plasmids from new designs (if any) =="
puts

designs.each do |design|

  plasmid = Part.find_by_biofab_id(design.plasmid_biofab_id)

  if design.plasmid_biofab_id.match(/\.0$/)
    design.plasmid_biofab_id = design.plasmid_biofab_id.gsub(/\.0$/, '')
    puts "fixing flawed biofab_id to #{design.plasmid_biofab_id}"
    plasmid.biofab_id = design.plasmid_biofab_id
    design.save!
    if !plasmid.save
      plasmid.delete
    end
  end

  # plasmid part already exists but design not associated
  if plasmid && design.plasmid_part_id.blank?
    design.plasmid_part_id = plasmid.id
    design.save!
    puts "Associated plasmid: #{design.plasmid_biofab_id}"
    next
  end


  plasmid = Part.new
  plasmid.part_type_id = part_type.id
  plasmid.biofab_id = design.plasmid_biofab_id
  plasmid.sequence = design.plasmid_sequence

  puts "Saving new plasmid: #{design.plasmid_biofab_id}"
  plasmid.save!

  design.plasmid_part_id = plasmid.id
  design.save!
end

puts
puts "done!"
