#!script/rails runner

g = Google.new(Settings['google_docs_key'], Settings['google_username'], Settings['google_password'])

g.default_sheet = 'FAB PLASMIDS'

part_type = PartType.find_by_name('Plasmid')
raise "could not find part type for Plasmid" if !part_type

row = 2
while(!g.cell(row, 1).blank?)

  biofab_id = "pFAB#{g.cell(row, 1).to_i}"

  part = Part.find_by_biofab_id(biofab_id)
  if !part
    puts "#{biofab_id} - new"

    part = Part.new
  else
    puts "#{biofab_id} - updating"  
  end
  
  part.biofab_id = biofab_id
  part.description = g.cell(row, 2)
  part.sequence = nil
  part.part_type = part_type

  begin
    part.save!
  rescue Exception => e
    puts "Failed to save #{biofab_id}: #{e.message}"
  end

  row += 1
end

