class PlasmidInfo < ActiveRecord::Base
  has_one :part

  before_validation do
    self.before_sequence = before_sequence.upcase.gsub(/[^ATGC]+/, '')
    self.after_sequence = after_sequence.upcase.gsub(/[^ATGC]+/, '')
  end


end
