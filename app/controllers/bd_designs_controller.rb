class BdDesignsController < ApplicationController
  layout 'bd_designs' #, :only => [:index]

  def index

    @annotations = [20,
                    {:sequence => 'AGGAGA',
                     :label => 'Static SD'},
                    44,
                   {:sequence => 'NNNGGANNN',
                     :label => 'Variable SD'},
                   9]

    @label = "Template for bi-cistronic 5' UTR library"


  end
end
