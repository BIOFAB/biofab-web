class Strain < ActiveRecord::Base

  belongs_to :organism
  belongs_to :plasmid, :class_name => 'Part'
  belongs_to :project
  has_many :performances
  has_many :replicates

  validates :biofab_id, :presence => true, :uniqueness => true

  scope :overview, includes([{:plasmid => [:part,
                                           {:eou => [:promoter, :five_prime_utr, :gene, :terminator]}]}, 
                             :organism])

   def promoter
    return nil unless plasmid && plasmid.eou
    plasmid.eou.promoter
  end

  def five_prime_utr
    return nil unless plasmid && plasmid.eou
    plasmid.eou.five_prime_utr
  end

  def gene
    return nil unless plasmid && plasmid.eou
    plasmid.eou.gene
  end

  def terminator
    return nil unless plasmid && plasmid.eou
    plasmid.eou.terminator
  end

  def to_sbol

    jars = ["#{Rails.root}/java/libSBOLcore.jar",
            "#{Rails.root}/java/libSBOLxml.jar"]
    
    Rjb::load(jars.join(':'))

    sURI = Rjb::import('java.net.URI')
    sParser = Rjb::import('org.sbolstandard.xml.Parser')
    sUtilURI = Rjb::import('org.sbolstandard.xml.UtilURI')
    sCollection = Rjb::import('org.sbolstandard.xml.CollectionImpl')
    sDnaComponent = Rjb::import('org.sbolstandard.xml.DnaComponentImpl')
    sDnaSequence = Rjb::import('org.sbolstandard.xml.DnaSequenceImpl')
    sSequenceAnnotation = Rjb::import('org.sbolstandard.xml.SequenceAnnotationImpl')

    uri = sUtilURI.Create("http://biofab.jbei.org/fake_collection")
    collection = sCollection.new(uri, "fake_collection", "A fake collection", "There is no reason for this.")
    uri = sUtilURI.Create("http://biofab.jbei.org/data/strains/#{id}")
    strain_component = sDnaComponent.new(uri, biofab_id, "Strain #{biofab_id}", "")
    dna_sequence = sDnaSequence.new(uri, sequence)
    strain_component.setSequence(dna_sequence)

    uri = sUtilURI.Create("http://biofab.jbei.org/data/EOUs/#{id}")
    annot = sSequenceAnnotation.new(uri)
    annot.setStrand("+")
    annot.setBioStart(plasmid.eou_insertion_point)
    annot.setBioEnd(plasmid.eou_insertion_point + plasmid.eou.sequence)
    eou_component = sDnaComponent.new(uri, eou.biofab_id, "EOU #{eou.biofab_id}", "")
    annot.setSubComponent(eou_component)

    strain_component.addAnnotation(annot)
    collection.addComponent(strain_component)

    parser = sParser.new
    parser.serialize(collection)

  end

  def sequence
    ps = plasmid.part.sequence
    ps1 = plasmid.part.sequence[0..plasmid.eou_insertion_point]
    ps2 = plasmid.part.sequence[plasmid.eou_insertion_point..-1]

    seq = ps1 + plasmid.eou.sequence + ps2
    return seq
  end

  def filename
    # TODO
    "fake_filename.sbol"
  end
 

end
