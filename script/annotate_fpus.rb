#!script/rails runner

# Script to annotate bi-cistronic 5' UTRs
# This script annotates the Makoff BCD parts with randomized SD2
# as well as the 22 Makoff BCD designs used in the BCD-GOI and PBD projects


# the part to use as a template for all non-variable annotations
# as long as it's one of vivek's makoff-based bi-cistronic designs it should be fine
# since they're all the same except for the SD2 sequence
parent_part_biofab_id = 'apFAB681'

$sd1 = 20..25
$cistron1_start = 32..34
$sd2 = 70..78
$stopstart = 83..87

# TODO implement for mono-cistronic
$msd1 = 12..20
$mstart = 27..29

puts "starting!"

type_name = 'SD'
$sd_type = PartType.find_by_name(type_name)
if !$sd_type
  $sd_type = PartType.new
  $sd_type.name = type_name
  $sd_type.description = 'Shine-Dalgarno sequence / Ribosome Binding Site'
  $sd_type.save!
  puts "created SD part type"
else
  puts "found SD part type"
end

type_name = 'Start codon'
start_type = PartType.find_by_name(type_name)
if !start_type
  start_type = PartType.new
  start_type.name = type_name
  start_type.description = 'A start codon / translation start site'
  start_type.save!
  puts "created start codon part type"
else
  puts "found start codon part type"
end

type_name = 'Stop and start codons'
stopstart_type = PartType.find_by_name(type_name)
if !stopstart_type
  stopstart_type = PartType.new
  stopstart_type.name = type_name
  stopstart_type.description = 'Overlapping stop and start codons.'
  stopstart_type.save!
  puts "created stopstart part type"
else
  puts "found stopstart part type"
end


project_name = "Bi-cistronic 5' UTR Library"
project_desc = "Vivek Mutalik's library of designed 5' UTR sequences."

project = Project.find_by_name(project_name)
if !project
  project = Project.new
  project.name = project_name
  project.save!
  puts "created project"
else
  puts "found project"
end

parent_part = Part.find_by_biofab_id(parent_part_biofab_id)

sd1_sequence = parent_part.sequence[$sd1]
$sd1_part = Part.find_by_sequence(sd1_sequence)
if !$sd1_part
  $sd1_part = Part.new
  $sd1_part.sequence = sd1_sequence
  $sd1_part.description = "The first shine-dalgarno sequence / ribosome binding site in the bi-cistronic designs."
  $sd1_part.part_type = $sd_type
  $sd1_part.save!
  puts "created sd1 part"
else
  puts "found sd1 part"
end
puts "-- #{$sd1_part.sequence}"

start_sequence = parent_part.sequence[$cistron1_start]
$start_part = Part.find_by_sequence(start_sequence)
if !$start_part
  $start_part = Part.new
  $start_part.sequence = start_sequence
  $start_part.description = "ATG start codon"
  $start_part.part_type = start_type
  $start_part.save!
  puts "created start part"
else
  puts "found start part"
end
puts "-- #{$start_part.sequence}"

stopstart_sequence = parent_part.sequence[$stopstart]
$stopstart_part = Part.find_by_sequence(stopstart_sequence)
if !$stopstart_part
  $stopstart_part = Part.new
  $stopstart_part.sequence = stopstart_sequence
  $stopstart_part.description = "Overlapping TAA and ATG stop and start sequences."
  $stopstart_part.part_type = stopstart_type
  $stopstart_part.save!
  puts "created stopstart part"
else
  puts "found stopstart part"
end
puts "-- #{$stopstart_part.sequence}"



def create_parts_and_annotations(part)
  
  puts
  puts "== Creating/finding SD2 part for #{part.biofab_id} =="

  sd2_sequence = part.sequence[$sd2]
  sd2_part = Part.find_by_sequence(sd2_sequence)
  if !sd2_part
    sd2_part = Part.new
    sd2_part.sequence = sd2_sequence
    sd2_part.description = "The second, and variable, Shine-Dalgarno / RBS sequence in a bi-cistronic design."
    sd2_part.part_type = $sd_type
    sd2_part.save!
    puts "--created sd2 part"
  else
    puts "--found sd2 part"
  end
  puts "---- #{sd2_part.sequence}"

  puts
  puts "== Creating/finding stopstart part for #{part.biofab_id} =="

  stopstart_sequence = part.sequence[$stopstart]
  stopstart_part = Part.find_by_sequence(stopstart_sequence)
  if !stopstart_part
    stopstart_part = Part.new
    stopstart_part.sequence = stopstart_sequence
    stopstart_part.description = "Overlapping stop and start codons."
    stopstart_part.part_type = $stopstart_type
    stopstart_part.save!
    puts "--created stopstart part"
  else
    puts "--found stopstart part"
  end
  
  puts
  puts "== Annotating #{part.biofab_id} =="

  annot_type_name = "Bi-cistronic 5' UTRs"
  annot_type = AnnotationType.find_by_name(annot_type_name)
  if !annot_type
    annot_type = AnnotationType.new
    annot_type.name = annot_type_name
    annot_type.save!
    puts "-- created annotation type for bicistronic 5' UTRs"
  else
    puts "-- found annotation type for bicistronic 5' UTRs"
  end
    
  sd1_label = "Static SD"
  start_label = "Start 1"
  sd2_label = "Mutated SD"
  stopstart_label = "Stop 1 / Start 2"

  create_annotation(part, $sd1_part, annot_type, $sd1.begin, $sd1.end, sd1_label)
  create_annotation(part, $start_part, annot_type, $cistron1_start.begin, $cistron1_start.end, start_label)
  create_annotation(part, sd2_part, annot_type, $sd2.begin, $sd2.end, sd2_label)
  create_annotation(part, stopstart_part, annot_type, $stopstart.begin, $stopstart.end, stopstart_label)

end


# Mono-cistronic version of above function
def create_parts_and_annotations_mcd(part)
  
  puts
  puts "== Creating/finding SD part for #{part.biofab_id} =="

  sd_sequence = part.sequence[$msd1]
  sd_part = Part.find_by_sequence(sd_sequence)
  if !sd_part
    sd_part = Part.new
    sd_part.sequence = sd_sequence
    sd_part.description = "The Shine-Dalgarno / RBS sequence in a mono-cistronic design."
    sd_part.part_type = $sd_type
    sd_part.save!
    puts "--created sd part"
  else
    puts "--found sd part"
  end
  puts "---- #{sd_part.sequence}"

  puts
  puts "== Creating start part for #{part.biofab_id} =="

  start_sequence = part.sequence[$mstart]
  start_part = Part.find_by_sequence(start_sequence)
  if !start_part
    start_part = Part.new
    start_part.sequence = start_sequence
    start_part.description = "Start codon."
    start_part.part_type = $start_type
    start_part.save!
    puts "--created start part"
  else
    puts "--found start part"
  end
  
  puts
  puts "== Annotating #{part.biofab_id} =="

  annot_type_name = "Mono-cistronic 5' UTRs"
  annot_type = AnnotationType.find_by_name(annot_type_name)
  if !annot_type
    annot_type = AnnotationType.new
    annot_type.name = annot_type_name
    annot_type.save!
    puts "-- created annotation type for mono-cistronic 5' UTRs"
  else
    puts "-- found annotation type for mono-cistronic 5' UTRs"
  end
    
  sd_label = "Mutated SD"
  start_label = "Start"

  create_annotation(part, sd_part, annot_type, $msd1.begin, $msd1.end, sd_label)
  create_annotation(part, start_part, annot_type, $mstart.begin, $mstart.end, start_label)

end

def create_annotation(parent_part, sub_part, annot_type, from, to, label=nil)
  if parent_part.blank? || sub_part.blank? || annot_type.blank? || from.blank? || to.blank?
    raise "problem with annotation!"
  end

  # don't create if it already exists
  annots = Annotation.where(["part_id = ? AND parent_part_id = ? AND `from` = ?", sub_part.id, parent_part.id, from]) #"
  if annots.length > 0
    annot = annots[0]
    puts "--updating existing annotation (annotation type and label only)"
  else
    annot = Annotation.new
    annot.parent_part = parent_part
    annot.part = sub_part
    annot.from = from
    annot.to = to
    puts "--creating new annotation"
  end

  annot.annotation_type = annot_type
  annot.label = label

  annot.save!
end

# add ATG to the end of BCD sequence if not already present
def fix_sequence(part)

  if part.sequence[-3..-1] == 'ATG'
    puts "--skipped #{part.biofab_id}"
    return part
  else
    part.sequence += 'ATG'
    part.save!
    puts "--fixed #{part.biofab_id}"
    return part
  end

end


def fetch_bcds

  fpu_type = PartType.find_by_name("5' UTR")
  raise "could not find 5' UTR part type" if !fpu_type
  
  # fetch the 22 makoff designs used for PBD library
  parts = fpu_type.parts.where("description like 'Chosen 22 BD Makoff%Full%'").all

  # fetch the 138 randomized makoff designs
  parts += fpu_type.parts.where("description like 'Makoff-BD_rand%'").all

  parts
end


def fetch_mcds

  fpu_type = PartType.find_by_name("5' UTR")
  raise "could not find 5' UTR part type" if !fpu_type
  
  # fetch the 22 mono-cistronic makoff designs
  parts = fpu_type.parts.where("description like 'Chosen 22 BD Makoff%Half%'").all

  # there are only the aboved-fetched 22 makoff designs

  parts
end


parts = fetch_bcds

puts "Fixing sequences (adding ATG where missing): "
parts.each do |part|
  fix_sequence(part)
end

puts "Creating sub-parts and annotations"
parts.each do |part|
  create_parts_and_annotations(part)
end


parts = fetch_mcds

puts "Fixing sequences (adding ATG where missing): "
parts.each do |part|
  fix_sequence(part)
end

puts "Creating sub-parts and annotations"
parts.each do |part|
  create_parts_and_annotations_mcd(part)
end

