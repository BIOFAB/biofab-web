#!script/rails runner

# run like this:
#   ./script/import_bc_designs.rb data/BD_data_for_the\ paper-Web.xlsx "PBD"

require 'script/math_stuff.rb'

def usage
  puts "This script imports designs from an xlsx file."
  puts "Usage: "
  puts "  #{__FILE__} <excel_sheet.xlsx> <sheet_name>"
  puts " "
  puts "  Reminder: Put quotes around sheet_name if it contains spaces."
  puts " "
end

def find_design_with(designs, promoter_biofab_id, fpu_biofab_id, reporter)

  designs.each do |design|
    if (design.fpu_biofab_id == fpu_biofab_id) && (design.promoter_biofab_id == promoter_biofab_id) && (design.reporter_gene == reporter)
      return design
    end
  end
  nil
end

if ARGV.length != 2
  usage()
  exit
end

filepath = ARGV[0]

x = Excelx.new(filepath)
x.default_sheet = ARGV[1]

designs = []

puts "Deleting all existing designs in 10 seconds: "

10.times do |i|
  sleep 1
  print '.'
  $stdout.flush
end
print "\n"

puts "Now deleting."

Design.delete_all

puts "Reading designs from xls file."

max_empty_rows = 20
blank_count = 0
row = 2
while(true)

  promoter_biofab_id = x.cell(row, 2)

  if promoter_biofab_id.blank?
    blank_count += 1
    if blank_count >= max_empty_rows
      puts "max blank count reached: #{blank_count} rows in a row. stopping loop"
      break
    end
    next
  else
    blank_count = 0
  end

  design = Design.new
  
  design.promoter_biofab_id = x.cell(row, 2).to_s.gsub(/\.\d+$/, '')
  design.promoter_name = x.cell(row, 3)
  design.promoter_sequence = x.cell(row, 4)
  design.fpu_biofab_id = x.cell(row, 5).to_s.gsub(/\.\d+$/, '')
  design.fpu_name = x.cell(row, 6)
  design.fpu_sequence = x.cell(row, 7)

  if !design.fpu_sequence.match(/ATG$/)
    design.fpu_sequence += 'ATG'
  end

  design.promoter_upstream_sequence = x.cell(row, 8)
  design.fpu_downstream_sequence = x.cell(row, 9)
  design.plasmid_sequence = x.cell(row, 10)
  design.reporter_gene = x.cell(row, 11).gsub(/\s+/, '').upcase

  # skip non-GFP values
#  if design.reporter_gene != 'GFP'
#    row += 1
#    next
#  end

  design.plasmid_biofab_id = "pFAB#{x.cell(row, 12).to_s.gsub(/\.0+$/,'')}"
  design.strain_name = x.cell(row, 13)
  design.antibiotic_marker = x.cell(row, 14)
  design.strain_biofab_id = "sFAB#{x.cell(row, 15).to_s.gsub(/\.0+$/,'')}"
  design.performance = x.cell(row, 16)
  design.performance_sd = x.cell(row, 17)

  designs << design

  row += 1
end

# find GFP and RFP means

plasmid_part_type = PartType.find_by_name('Plasmid')

puts "saving #{designs.length} designs: "
count = 1
designs.each do |design|

  part = Part.find_by_biofab_id(design.promoter_biofab_id)
  raise "no promoter found with: #{design.promoter_biofab_id}" if !part
  design.promoter_part_id = (part) ? part.id : nil

  part = Part.find_by_biofab_id(design.fpu_biofab_id)
  raise "no 5' UTR found with: #{design.fpu_biofab_id}" if !part
  design.fpu_part_id = (part) ? part.id : nil

  part = Part.find_by_biofab_id(design.plasmid_biofab_id)
  if !part
    part = Part.new
    part.biofab_id = design.plasmid_biofab_id
    part.sequence = design.plasmid_sequence
    part.part_type = plasmid_part_type
    part.save!
  elsif part.sequence.blank?
    part.sequence = design.plasmid_sequence
  end

  raise "no plasmid found with: #{design.plasmid_biofab_id}" if !part

  design.plasmid_part_id = (part) ? part.id : nil

  design.strain_part_id = nil

  print '.'
  print '|' if count % 100 == 0
  print '|' if count % 1000 == 0
  $stdout.flush
  design.save!
  count += 1
end

puts "\ndone saving designs"
