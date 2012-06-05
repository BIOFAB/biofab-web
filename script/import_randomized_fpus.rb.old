#!script/rails runner

# run like this:
#   ./script/import_bc_designs.rb data/BD_data_for_the\ paper-Web_final_from_vivek.xlsx "Randomized"

require 'script/math_stuff'

def usage
  puts "This script imports designs from an xlsx file."
  puts "Usage: "
  puts "  #{__FILE__} <excel_sheet.xlsx> <sheet_name>"
  puts " "
  puts "  Reminder: Put quotes around sheet_name if it contains spaces."
  puts " "
end

if ARGV.length != 2
  usage()
  exit
end

filepath = ARGV[0]

x = Excelx.new(filepath)

x.default_sheet = ARGV[1]

designs = []

puts "Deleting all existing RandomizedBds in 10 seconds: "

10.times do |i|
  sleep 1
  print '.'
  $stdout.flush
end
print "\n"

puts "Now deleting."

RandomizedBd.delete_all

puts "Reading designs from xls file."

max_empty_rows = 20
blank_count = 0
row = 2
while(true)

  fpu_biofab_id = x.cell(row, 2)

  if fpu_biofab_id.blank?
    blank_count += 1
    if blank_count >= max_empty_rows
      puts "max blank count reached: #{blank_count} rows in a row. stopping loop"
      break
    end
    next
  else
    blank_count = 0
  end

  design = RandomizedBd.new
  design.biofab_id = x.cell(row, 2)
  design.sequence = x.cell(row, 3).upcase
  design.plasmid_sequence = x.cell(row, 6).upcase
  design.plasmid_biofab_id = 'pFAB' + x.cell(row, 7).to_s.gsub(/\.\d+$/, '')
  design.strain_biofab_id = 'sFAB' + x.cell(row, 8).to_s.gsub(/\.\d+$/, '')
  design.strain = x.cell(row, 9)
  design.antibiotic_marker = x.cell(row, 10)
  design.ori = x.cell(row, 11)

  design.fcs = x.cell(row, 12).to_f
  design.fcs_sd = x.cell(row, 13).to_f

 # fix missing ATG
  if design.sequence[-3..-1] != 'ATG'
    design.sequence += 'ATG'
  end

  designs << design

  row += 1
end

puts "associating #{designs.length} designs with fpu and plasmid parts"
count = 1
designs.each do |design|

  part = Part.find_by_biofab_id(design.biofab_id)
  raise "no 5' UTR found with: #{design.biofab_id}" if !part
  design.part_id = (part) ? part.id : nil

  part = Part.find_by_biofab_id(design.plasmid_biofab_id)
  raise "no plasmid found with: #{design.plasmid_biofab_id}" if !part
  design.plasmid_part_id = (part) ? part.id : nil

  print '.'
  print '|' if count % 100 == 0
  print '|' if count % 1000 == 0
  $stdout.flush
  count += 1
end

puts
puts "== Finding max =="

values = designs.collect {|design| design.fcs}
max = values.max


puts
puts "== Normalizing performances to 0-100 and saving =="

count = 1
designs.each do |design|

  design.fcs_normalized = (design.fcs / max) * 100
  design.fcs_sd_normalized = (design.fcs_sd / max) * 100

  print '.'
  print '|' if count % 100 == 0
  print '|' if count % 1000 == 0
  $stdout.flush
  design.save!
  count += 1
end



