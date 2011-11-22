class Part < ActiveRecord::Base
  has_many :annotations
  # only if this is a plasmid or chromosomally integrated sequence
  belongs_to :plasmid_info 
  belongs_to :part_type
  belongs_to :project

  before_validation do
    self.sequence = sequence.upcase.gsub(/[^ATGC]+/, '')
    if sequence == ''
      self.sequence = nil
    end
  end

  validates :biofab_id, :presence => true, :uniqueness => true
  validates :sequence, :uniqueness => true


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

end
