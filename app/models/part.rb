class Part < ActiveRecord::Base

  has_many :annotations, :foreign_key => :parent_part_id
  # only if this is a plasmid or chromosomally integrated sequence
  belongs_to :plasmid_info 
  belongs_to :part_type
  belongs_to :project


  before_validation do
    if !self.sequence.blank?
      self.sequence = sequence.upcase.gsub(/[^ATGC]+/, '')
    else
      self.sequence = nil
    end
  end

  validates :biofab_id, :uniqueness => true
#  validates :sequence, :uniqueness => true


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


end
