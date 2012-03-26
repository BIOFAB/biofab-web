#!script/rails runner

# last part ID: 5149

g = Google.new(Settings['google_docs_key'], Settings['google_username'], Settings['google_password'])

g.default_sheet = 'FAB PLASMIDS'

last_part = Part.last

puts "Last part ID: #{last_part.id}"
puts

part_type = PartType.find_by_name('Plasmid')
if !part_type
  part_type = PartType.new
  part_type.name = 'Plasmid'
  part_type.save!
end

row = 2
while(!g.cell(row, 1).blank?)
  biofab_id = "pFAB#{g.cell(row, 1).to_i}"

  description = g.cell(row, 2)

  sequence = nil
  design = nil
  bd_design = nil

  design = Design.find_by_plasmid_biofab_id(biofab_id)
  if design
    sequence = design.plasmid_sequence
  end
  bc_design = BcDesign.find_by_plasmid_biofab_id(biofab_id)
  if bc_design && !sequence
    sequence = bc_design.plasmid_sequence
  end

  part = Part.find_by_biofab_id(biofab_id)
  if part
    puts "Updating part: #{part.biofab_id}"
  else
    existing = Part.where(["sequence = ? AND biofab_id <> ?", sequence, biofab_id]).first
    raise "-- This is a duplicate of existing part #{existing.biofab_id}" if existing
    puts "New part: #{biofab_id}"
    part = Part.new
  end

  part.biofab_id = biofab_id
  part.sequence = sequence
  part.part_type = part_type

  begin
    part.save!
  rescue Exception => e
    puts "Failed to save #{biofab_id}: #{e.message}"
  end

  if design
    design.plasmid_part_id = part.id
    design.save!
  end

  if bc_design
    bc_design.plasmid_part_id = part.id
    bc_design.save!
  end

  row += 1
end

