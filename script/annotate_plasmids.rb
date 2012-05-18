#!script/rails runner

type_name = "EOU element"
anno_type = AnnotationType.find_by_name(type_name)
if !anno_type
  anno_type = AnnotationType.new
  anno_type.name = type_name
  anno_type.save!
end

puts "Deleting all 'EOU element'-type annotations in 10 seconds: "
10.times do |i|
  sleep 1
  print '.'
  $stdout.flush
end
print "\n"
puts "Now deleting."

raise "no annotation type id!" if !anno_type.id

annots = Annotation.delete_all(["annotation_type_id = ?", anno_type.id])


plasmid_type = PartType.find_by_name('Plasmid')
raise "plasmid type not found" if !plasmid_type

plasmids = Part.where(["part_type_id = ?", plasmid_type.id])
raise "no plasmids found" if !plasmids || (plasmids.length == 0)

# Only get allowed part types
allowed_part_type_names = ["Promoter",
                           "CDS",
                           "5' UTR",
                           "Terminator",
                           "Resistance marker",
                           "Spacer",
                           "Insulator",
                           "Replication origin"]

query_parm = [(["name = ?"] * allowed_part_type_names.length).join(' OR ')] + allowed_part_type_names

allowed_part_types = PartType.where(query_parm)
raise "no part types found" if !allowed_part_types || (allowed_part_types.length == 0)

query_parm = [(["part_type_id = ?"] * allowed_part_types.length).join(' OR ')] + allowed_part_types.map(&:id)

parts = Part.where(query_parm)
raise "no parts found" if !parts || (parts.length == 0)



plasmids.each do |plasmid| 
  next if plasmid.sequence.blank?

  puts "annotating plasmid #{plasmid.biofab_id}"

  annotations = []

  parts.each do |part|
    next if part.sequence.blank?
    offset = 0

    # TODO ugly hack to ignore a second terminator present on some plasmids
    next if part.biofab_id == 'apFAB840'
    next if part.biofab_id == 'apFAB861'

    mseq = plasmid.sequence.upcase

    while(m = mseq.match(part.sequence.upcase))

      annot_from = m.begin(0) + offset
      annot_to = m.end(0) + offset - 1

      anno = Annotation.new
      anno.parent_part = plasmid
      anno.part = part
      anno.from = annot_from
      anno.to = annot_to
      anno.annotation_type_id = anno_type.id
      annotations << anno

      offset += m.end(0)
      mseq = mseq[offset..-1]
      
    end
  end

  final_annos = []

  annotations.each do |inner|
    keep = true
    annotations.each do |outer|
      next if outer == inner
      if (outer.from <= inner.from) && (outer.to >= inner.to)
        keep = false
      end
    end
    if keep
      final_annos << inner
    end
  end

  final_annos.each do |anno|
    puts "saving annotation for plasmid part: #{plasmid.id}"
    anno.save!
  end

end
