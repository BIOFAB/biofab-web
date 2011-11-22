class Eou < ActiveRecord::Base
  belongs_to :promoter, :class_name => 'Part'
  belongs_to :five_prime_utr, :class_name => 'Part'
  belongs_to :cds, :class_name => 'Part'
  belongs_to :terminator, :class_name => 'Part'
  has_many :plasmids, :class_name => 'Part'

  def sequence
    promoter.sequence + five_prime_utr.sequence + gene.sequence + terminator
  end

  def parts
    [promoter, five_prime_utr, cds, terminator]
  end

  def descriptor(opts={})
    descs = []
    parts.each do |part|
      if part
        descs << part.biofab_id_descriptor
      else
        descs << 'NA' unless opts[:hide_NA]
      end
    end
    descs.join(' | ')
  end

end
