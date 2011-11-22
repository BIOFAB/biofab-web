class Organism < ActiveRecord::Base
  has_many :strains

  validates_presence_of :species
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_nil => true, :allow_blank => true

  def self.descriptors
    all.collect do |organism|
      organism.descriptor
    end
  end

  def descriptor
    if !substrain.strip.blank?
      "#{species}: #{strain}: #{substrain}"
    else
      "#{species}: #{strain}"
    end
  end

  def brief_descriptor
    if !substrain.blank?
      return substrain
    elsif !strain.blank?
      return strain
    elsif !species.blank?
      return species
    else
      return "NA"
    end
  end

  def to_s
    "#{substrain}"
  end

end
