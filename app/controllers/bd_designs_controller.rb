class BdDesignsController < ApplicationController
  layout 'bd_designs' #, :only => [:index]

  def index

    bcd_data = PartPerformance.where("name like 'BCD%'").includes(:part => :annotations).all

    # sort by BCD1, BCD2, etc. number
    bcd_sorted = bcd_data.sort do |a,b|
#      a.name.gsub(/[^\d]+/,'').to_i <=> b.name.gsub(/[^\d]+/,'').to_i
      -a.goi_average <=> -b.goi_average
    end

    @bcd_labels = bcd_sorted.collect(&:name)
    @bcd_data = bcd_sorted.collect(&:goi_average)
    @bcd_sd = bcd_sorted.collect(&:goi_sd)

    # get the RBS2 sequences
    @bcd_rbs2_seqs = bcd_sorted.collect do |perf|
      seq = nil
      perf.part.annotations.each do |annot|
        if annot.label == 'Mutated SD'
          seq = annot.part.sequence
        end
      end
      seq
    end

    @bcd_rbs2_seqs.compact!

    mcd_data = PartPerformance.where("name like 'MCD%'").all

    mcd_order = bcd_sorted.collect do |bcd|
      'MCD' + bcd.name.gsub(/[^\d]+/,'')
    end

    # sort by MCD1, MCD2, etc. number
    mcd_sorted = mcd_data.sort_by do |mcd|
      mcd_order.index(mcd.name)
    end

    @mcd_labels = mcd_sorted.collect(&:name)
    @mcd_data = mcd_sorted.collect(&:goi_average)
    @mcd_sd = mcd_sorted.collect(&:goi_sd)

    # get the RBS2 sequences
    @mcd_rbs2_seqs = mcd_sorted.collect do |perf|
      seq = nil
      perf.part.annotations.each do |annot|
        if annot.label == 'Mutated SD'
          seq = annot.part.sequence
        end
      end
      seq
    end

    @bcd_rbs2_seqs.compact!


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

  def get_per_goi_data

    designs = BcDesign.where(["fpu_name = ?", params['fpu_name']])

    cds_names = designs.collect(&:cds_name)
    fc_averages = designs.collect(&:fc_average)
    fc_sds = designs.collect(&:fc_sd)
    params = designs.collect do |design|
      {:bc_design_id => design.id}
    end
    

    render :text => {

      :labels => cds_names,
      :data => fc_averages,
      :errors => fc_sds,
      :params => params

    }.to_json
    

  end


  def get_plasmid_json

    design = BcDesign.find(params['bc_design_id'])

    render :text => {
      :name => design.plasmid.biofab_id,
      :sequence => design.plasmid.sequence,
      :features => design.plasmid.annotations_for_flash_widgets
    }.to_json

  end

end
