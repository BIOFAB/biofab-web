#!script/rails runner

types = [
         ["Promoter", nil],
         ["5' UTR", nil],
         ["CDS", nil],
         ["Terminator", nil],
         ["Plasmid", nil],
         ["Terminator", nil],
         ["Resistance marker", nil],
         ["Replication origin", nil],
         ["-35", "Promoter -35 region"],
         ["-10", "Promoter -10 region"],
         ["+1", "Promoter +1 / transcription start site"],
         ["Modular Promoter Library 5' module", nil],
         ["Modular Promoter Library 3' module", nil],
         ["Modular Promoter Library middle module", nil],
         ["SD", "Shine-Dalgarno sequence / Ribosome Binding Site"],
         ["Start codon", "A start codon / translation start site"],
         ["Stop and start codons", "Overlapping stop and start codons."],
         ["Spacer", nil],
         ["Pause", "A pause site"],
         ["Insulator", nil]
]


def create_type(name, description)

  if PartType.find_by_name(name)
    puts "Type '#{name}' already in database. Skipping."
    return nil
  end

  type = PartType.new
  type.name = name
  type.description = description
  type.save!
  puts "Added type '#{name}'"

end

types.each do |type|
  create_type(type[0], type[1])
end

puts "Completed"
