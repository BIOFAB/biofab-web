# -*- coding: utf-8 -*-
class Part < ActiveRecord::Base

  has_many :annotations, :foreign_key => :parent_part_id
  # only if this is a plasmid or chromosomally integrated sequence
  belongs_to :plasmid_info 
  belongs_to :part_type
  belongs_to :project
  has_one :part_performance

  before_validation do
    if !self.sequence.blank?
      self.sequence = sequence.upcase.gsub(/[^ATGC]+/, '')
    else
      self.sequence = nil
    end
  end

  validates :biofab_id, :uniqueness => true

  def self.promoters
    joins(:part_type).where("part_types.name = 'Promoter'")
  end

  def self.promoter_descriptors
    self.promoters.all.collect {|part| part.descriptor}
  end

  def self.five_prime_utrs
    joins(:part_type).where("part_types.name = \"5' UTR\"")
  end

  def self.five_prime_utr_descriptors
    self.five_prime_utrs.all.collect {|part| part.descriptor}
  end

  def self.cdss
    joins(:part_type).where("part_types.name = 'CDS'")
  end

  def self.cds_descriptors
    self.cdss.all.collect {|part| part.descriptor}
  end

  def self.terminators
    joins(:part_type).where("part_types.name = 'Terminator'")
  end

  def self.terminator_descriptors
    self.terminators.all.collect {|part| part.descriptor}
  end

  def biofab_id_descriptor
    (biofab_id.blank?) ? 'NO_ID' : biofab_id
  end

  def self.by_id(id)
    self.where(["biofab_id = ? OR duplicates like ?", id, "%!#{id}!%"]).first
  end

  def descriptor
    "#{biofab_id}: #{description}"
  end

  def to_s
    biofab_id
  end

  # TODO this require be needing some optimizin' fool!
  def annotations_with_type_recursive(type_name=nil, annots=nil, offset=0)
    annots = annots || annotations.includes(:annotation_type)
    matches = []
    annots.each do |anno|
      next if !anno.part
      next if anno.part.annotations.length == 0
      matches += annotations_with_type_recursive(type_name, anno.part.annotations.includes(:annotation_type), anno.from)
    end
    annots.each do |anno|
      if !type_name || (anno.annotation_type.name == type_name)
        anno.offset = offset
        matches << anno
      end
    end
    matches.sort {|a,b| a.from_offset <=> b.from_offset}
  end

  def annotations_with_part_types_recursive(type_names, annots=nil, offset=0)
    annots = annots || annotations.includes(:part => :part_type)
    matches = []
    annots.each do |anno|
      next if !anno.part
      next if anno.part.annotations.length == 0
      matches += annotations_with_part_types_recursive(type_name, anno.part.annotations.includes(:part => :part_type), anno.from)
    end
    annots.each do |anno|
      if type_names.include?(anno.part.part_type.name)
        anno.offset = offset
        matches << anno
      end
    end
    matches.sort {|a,b| a.from_offset <=> b.from_offset}
  end

  def annotations_with_type(type_name)
    annotations.joins(:annotation_type).where(["annotation_types.name = ?", type_name])
  end

  def annotations_for_flash_widgets(type_name=nil)
    annots = nil
    if type_name
      annots = annotations_with_type(type_name)
    else
      annots = annotations
    end
    annots = annots.includes(:part => :part_type).all

    annots.collect do |annot|
      {
        :name => annot.label || annot.part.description,
        :type => annot.part.part_type.name,
        :from => annot.from,
        :to => annot.to + 1
      }
    end
  end

  def annotations_recursive
    sub_annots = []
    annotations.each do |annotation|
      next if !annotation.part
      sub_annots += annotation.part.annotations_recursive
    end
    annotations + sub_annots
  end

  def to_genbank
    seq = Bio::Sequence.new(sequence)
    seq.features = []

    annotations_recursive.each do |annotation|
      seq.features << Bio::Feature.new(annotation.part.part_type.name, "#{annotation.from}..#{annotation.to}",
                                       [ Bio::Feature::Qualifier.new('biofab_id', annotation.part.biofab_id)])
    end

    seq.output(:genbank)
  end

  def to_fasta
    seq = Bio::Sequence::NA.new(sequence)
    seq.to_fasta(biofab_id)
  end

  def self.collection_to_sbol(parts)
    xml = <<eos
<?xml version="1.0" ?>
<rdf:RDF
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:s="http://sbols.org/v1#"
  xmlns:so="http://purl.obolibrary.org/obo/"
  xmlns:d="http://sbols.org/data#">
eos

    xml += "<s:Collection>"

    parts.each do |part|
      xml += part.to_sbol_component
    end

    xml += "</s:Collection>"
    xml += "</rdf:RDF>"
  end


  def to_sbol

    xml = <<eos
<?xml version="1.0" ?>
<rdf:RDF
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:s="http://sbols.org/v1#"
  xmlns:so="http://purl.obolibrary.org/obo/"
  xmlns:d="http://sbols.org/data#">
eos

    component_xml = to_sbol_component
    return nil if !component_xml 

    xml += component_xml

    xml += "</rdf:RDF>"

  end

  def to_sbol_component

    return nil if !biofab_id

    xml = "<s:DnaComponent rdf:about=\"#{biofab_id}\">"
    
    xml += "<s:displayId>#{biofab_id}</s:displayId>"
    xml += "<s:name>#{biofab_id}</s:name>"
    xml += "<s:description>BIOFAB part #{biofab_id} of type #{part_type.name}</s:description>"

    xml += "<s:dnaSequence><s:DnaSequence rdf:about=\"#{biofab_id}.DnaSequence\"><s:nucleotides>#{sequence}</s:nucleotides></s:DnaSequence></s:dnaSequence>"

    annots_with_biofab_id = 0
    annotations.each do |annot|
      if !annot.part.biofab_id.blank?
        annots_with_biofab_id += 1
      end
    end

    if annots_with_biofab_id > 0
      xml += "<s:annotation>"

      annotations.each do |annotation|
        next if annotation.part.biofab_id.blank?

        xml += "<s:SequenceAnnotation rdf:about=\"#{annotation.part.biofab_id}.SequenceAnnotation\">"

        xml += "<s:bioStart>#{annotation.from}</s:bioStart>"
        xml += "<s:bioEnd>#{annotation.to}</s:bioEnd>"
        xml += "<s:strand>+</s:strand>"
        xml += "<s:subComponent>"
        xml += annotation.part.to_sbol_component
        xml += "</s:subComponent>"
        xml += "</s:SequenceAnnotation>"
      end
      
      xml += "</s:annotation>"
    end

    xml += "</s:DnaComponent>"

    xml
  end

end
