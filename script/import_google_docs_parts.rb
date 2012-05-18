#!script/rails runner

g = Google.new(Settings['google_docs_key'], Settings['google_username'], Settings['google_password'])

g.default_sheet = 'PARTS'

row = 2
while(!g.cell(row, 1).blank?)
  biofab_id = "apFAB#{g.cell(row, 1).to_i}"

  type = g.cell(row, 2)
  if type.blank?
    row += 1
    next
  end
   
  description = g.cell(row, 3)
  sequence = g.cell(row, 4)

  if sequence
    sequence = sequence.upcase.gsub(/[^GATC]+/, '')
  end

  type_query = type.gsub(/[^\w\d]+/, ' ').downcase
  part_type = PartType.where("name like '#{type_query}'").first

  if !part_type
    type_query = '%' + type.gsub(/[^\w\d]+/, '%') + '%'
    part_type = PartType.where("name like '#{type_query}'").first
    if !part_type
      puts "Failed for #{biofab_id} to find part type based on: #{type}"
      exit
    end
  end

  part = Part.where(["biofab_id = ?", biofab_id]).first
  if part
    puts "Updating part: #{part.biofab_id}"
  else

    existing = Part.where(["sequence = ? AND biofab_id <> ?", sequence, biofab_id]).first
    if existing
      puts "-- This is a duplicate of existing part #{existing.biofab_id}"
      if !existing.duplicates.blank?
        duplicates = existing.duplicates.gsub('!', '').split(',')
      else
        duplicates = []
      end
      if !duplicates.index(biofab_id)
        duplicates << biofab_id
        existing.duplicates = duplicates.collect {|dupe| "!#{dupe}!"}.join(',')
        existing.save!
      end

      row += 1
      next
    end    


    puts "New part: #{biofab_id}"
    part = Part.new
  end


  part.biofab_id = biofab_id
  part.sequence = sequence
  part.description = description
  part.part_type = part_type

  begin
    part.save!
#    puts "Imported #{biofab_id}"
  rescue Exception => e
    puts "Failed to save #{biofab_id}: #{e.message}"
  end

  row += 1
end

puts "remember to run annotate_fpus.rb now, in order to add ATG to the end of 5' UTRs"
