class BdDesignsController < ApplicationController
  layout 'bd_designs' #, :only => [:index]

  def index

    @bcd_annotations = [19,
                    {:sequence => 'AGGAGA',
                     :label => 'Static SD'},
                    7,
                    {:sequence => 'ATG',
                     :label => 'Start cistron 1'},
                    36,                    
                   {:sequence => 'NNNGGANNN',
                     :label => 'Variable SD'},
                    5,                    
                   {:sequence => 'TAATG',
                     :label => 'Stop 1 / Start 2'}]

    @mcd_annotations = [12,
                   {:sequence => 'NNNGGANNN',
                     :label => 'Variable SD'},
                    6,
                   {:sequence => 'ATG',
                     :label => 'Start'}]



# <%= render :partial => '/parts/diagram', :locals => {:part => @part, :annotations => @part.annotations_with_type_recursive, :performance => 0.5, :classes => ''} %>

#    @part = Part.find(params[:id], :include => {:annotations => :annotation_type})
#    @performance = 0.6 # expression level (optional)

  end
end
