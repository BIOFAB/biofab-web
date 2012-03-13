#!script/rails runner

def create_annotation(part, sub_part, annot_type, range=nil)

  from = 0
  to = 0

  if sub_part && sub_part.sequence
#    if part.sequence.scan(sub_part.sequence).length > 1
#      raise "Sub-part appears twice in part: #{part.biofab_id} - #{part.sequence} - #{sub_part.sequence}"
#    end
    m = part.sequence.match(sub_part.sequence)
    if !m
      return nil
    end
    from = m.begin(0)
    to = m.end(0) - 1
    puts "  found #{sub_part.part_type.name} [#{sub_part.sequence}] at #{from}:#{to} in #{part.sequence}"
  elsif range
    from = range.begin
    to = range.end
    puts "  annotating #{sub_part.part_type.name} [] at #{from}:#{to} in #{part.sequence}"
  else
    raise "need either sub_part or range"
  end

  annots = Annotation.where(["part_id = ? AND parent_part_id = ? AND `from` = ?", sub_part.id, part.id, from]) # "
  if annots.length > 0
    annot = annots[0]
  else
    annot = Annotation.new
    annot.parent_part = part
    annot.part = sub_part
    annot.from = from
  end

  annot.annotation_type = annot_type
  annot.to = to

  annot
end

mpl_names = ['Pt7a1',
             'pTrc',
             'T5 N25',
             'Busby; NM535 series',
             'U56D46(P RM)']

module1 = ['AAAAAGAGTATTGACT',
           'TTGACA',
           'AAAAATTTATTTGCTT',
           'TCGACA',
           'CACGGTGTTAGACA']

module2 = ['TAAAGTCTAACCTATAGG',
           'ATTAATCATCCGGCTCG',
           'TCAGGAAAATTTTTCTG',
           'TCGCATCTTTTTGTACC',
           'TTTATCCCTTGCGGCGA']

module3 = ['ATACTTACAGCCAT',
           'TATAATGTGTGGAT',
           'TATAATAGATTCAT',
           'CATAATTATTTCAT',
           'TAGATTTAACGTAt']

mpl35 = ['TTGACT',
         'TTGACA',
         'TTGCTT',
         'TCGACA',
         'TAGACA']

mpl10 = ['ATACTT',
         'TATAAT',
         'CATAAT',
         'TAGATT']

# indices for random promoter library regions
rpl35 = 0..5
rpl10 = 23..28

modular = Project.find_by_name("Modular Promoter Library")
if !modular
  raise "no modular promoter project found"
end
random = Project.find_by_name("Random Promoter Library")
if !random
  raise "no random promoter project found"
end

raise "could not find projects" if !modular || !random

# Annotation types
mod_annot_type = AnnotationType.find_by_name("Modular Promoter Library modules")
if !mod_annot_type
  raise "could not find modular promoter type"
end

promoter_annot_type = AnnotationType.find_by_name("Promoter transcription")
if !mod_annot_type
  raise "could not find promoter transcription type"
end

# Promoter part type
promoter_type = PartType.find_by_name("Promoter")
if !mod_annot_type
  raise "could not find promoter part type"
end

# MPL part types
five_type = PartType.find_by_name("Modular Promoter Library 5' module")
if !five_type
  raise "could not find MPL type"
end

mid_type = PartType.find_by_name("Modular Promoter Library middle module")
if !mid_type
  raise "could not find MPL type"
end

three_type = PartType.find_by_name("Modular Promoter Library 3' module")
if !three_type
  raise "could not find MPL type"
end

# Promoter part types
minus35type = PartType.find_by_name("-35")
if !minus35type
  raise "could not find -35 type"
end

minus10type = PartType.find_by_name("-10")
if !minus10type
  raise "could not find -10 type"
end

plus1type = PartType.find_by_name("+1")
if !plus1type
  raise "could not find +1 type"
end

# Create plus1part if it dosn't exist
puts "== Creating +1 part =="

plus1part = Part.find_by_part_type_id(plus1type.id)
if !plus1part
  plus1part = Part.new
  plus1part.description = "Part used to annotate +1."
  plus1part.part_type = plus1type
  plus1part.save!
end

# create new parts (if they don't already exist)

puts "Creating 5' module parts for MPL"
module1.each_index do |i|
  m = module1[i].upcase
  m_name = mpl_names[i]
  if Part.where(["sequence = ? AND part_type_id = ?", m, five_type.id]).length > 0
    puts "  skipping: #{m}"
    next
  end
  part = Part.new
  part.sequence = m
  part.part_type = five_type
  part.description = "5' module from Modular Promoter Library. Derived from promoter: #{m_name}"
  part.project = modular
  puts "  adding: #{m}"
  part.save!
  puts "    id: #{part.id}"
end

puts "Creating middle module parts for MPL"
module2.each_index do |i|
  m = module2[i].upcase
  m_name = mpl_names[i]
  if Part.where(["sequence = ? AND part_type_id = ?", m, mid_type.id]).length > 0
    puts "  skipping: #{m}"
    next
  end
  part = Part.new
  part.sequence = m
  part.part_type = mid_type
  part.description = "Middle module from Modular Promoter Library. Derived from promoter: #{m_name}"
  part.project = modular
  puts "  adding: #{m}"
  puts "    id: #{part.id}"
  part.save!
end

puts "Creating 3' module parts for MPL"
module3.each_index do |i|
  m = module3[i].upcase
  m_name = mpl_names[i]
  if Part.where(["sequence = ? AND part_type_id = ?", m, three_type.id]).length > 0
    puts "  skipping: #{m}"
    next
  end
  part = Part.new
  part.sequence = m
  part.part_type = three_type
  part.description = "3' module from Modular Promoter Library. Derived from promoter: #{m_name}"
  part.project = modular
  puts "  adding: #{m}"
  puts "    id: #{part.id}"
  part.save!
end

# Create -35, -10 and +1 parts for MPL

puts "Creating -35 parts for MPL"
mpl35.each_index do |i|
  m = mpl35[i].upcase
  m_name = mpl_names[i]
  if Part.where(["sequence = ? AND part_type_id = ?", m, minus35type.id]).length > 0
    puts "  skipping: #{m}"
    next
  end
  part = Part.new
  part.sequence = m
  part.part_type = minus35type
  part.description = "-35 region from Modular Promoter Library. Derived from promoter: #{m_name}"
  part.project = modular
  puts "  adding: #{m}"
  puts "    id: #{part.id}"
  part.save!
end


puts "Creating -10 parts for MPL"
mpl10.each_index do |i|
  m = mpl10[i].upcase
  m_name = mpl_names[i]
  if Part.where(["sequence = ? AND part_type_id = ?", m, minus10type.id]).length > 0
    puts "  skipping: #{m}"
    next
  end
  part = Part.new
  part.sequence = m
  part.part_type = minus10type
  part.description = "-10 region from Modular Promoter Library. Derived from promoter: #{m_name}"
  part.project = modular
  puts "  adding: #{m}"
  puts "    id: #{part.id}"
  part.save!
end

mpl_promoters = modular.parts.where(:part_type_id => promoter_type.id)
modules = modular.parts.where(:part_type_id =>[five_type.id, mid_type.id, three_type.id])
promoter_regions = modular.parts.where(:part_type_id => [minus35type.id, minus10type.id, plus1type.id])

puts
puts "== Creating RPL -35, 10 parts and -35, -10, +1 annotations =="

random_promoters = random.parts.where(:part_type_id => promoter_type.id)


random_promoters.each do |part|
  next if part.sequence.blank?

  puts "||part: #{part.biofab_id}"

  m35 = Part.new
  m35.sequence = part.sequence[rpl35]
  m35.part_type = minus35type
  m35.description = "Mutated -35 region from Random Promoter Library."
  m35.project = random

  existing = Part.where(["sequence = ? AND part_type_id = ?", m35.sequence, minus35type.id])

  if existing.length > 0
    puts "  -35 skipping: #{m35.sequence}"
    m35 = existing[0]
  else
    puts "  -35 adding: #{m35.sequence}"
    m35.save!
  end


  m10 = Part.new
  m10.sequence = part.sequence[rpl10]
  m10.part_type = minus10type
  m10.description = "Mutated -10 region from Random Promoter Library."
  m10.project = random

  existing = Part.where(["sequence = ? AND part_type_id = ?", m10.sequence, minus10type.id])

  if existing.length > 0
    puts "  -10 skipping: #{m10.sequence}"
    m10 = existing[0]
  else
    puts "  -10 adding: #{m10.sequence}"
    m10.save!
  end


  annot = create_annotation(part, m35, promoter_annot_type)
  if annot
    annot.save!
    puts "  -35 adding/updating annotation #{annot.id}"
  end

  annot = create_annotation(part, m10, promoter_annot_type)
  if annot
    annot.save!
    puts "  -10 adding/updating annotation"
  end

  from = part.sequence.length - 1
  to = from

  annot = create_annotation(part, plus1part, promoter_annot_type, from..to)
  if annot
    annot.save!
    puts "  +1 adding/updating annotation #{annot.id}"
  end

end

annotations = []

puts "== Creating MPL annotations (not saving until the end) =="

puts "Creating annotations for modules"

modules.each do |part|
  promoter_regions.each do |sub_part|
    next if part.sequence.blank? || sub_part.sequence.blank?
    
    annot = create_annotation(part, sub_part, promoter_annot_type)
    next if !annot

    annotations << annot
  end
end

puts "Creating annotations for MPL promoters"

# mpl promoter module annotation
mpl_promoters.each do |part|
  modules.each do |sub_part|
    next if part.sequence.blank? || sub_part.sequence.blank?

    annot = create_annotation(part, sub_part, mod_annot_type)
    next if !annot

    annotations << annot
  end
end

mpl_promoters.each do |part|
  next if part.sequence.blank?

  from = part.sequence.length - 1
  to = from

  annot = create_annotation(part, plus1part, promoter_annot_type, from..to)
  next if !annot

  annotations << annot
end

puts " "
puts "== Saving #{annotations.length} annotations =="

annotations.each do |annot|
  annot.save!
end

puts "Saving completed!"
