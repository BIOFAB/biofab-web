class SimpleController < ApplicationController
  layout 'simple' #, :only => [:index]

  # pdb
  def index

      @designs = Design.includes({:promoter => [:part_performance], :fpu => [:part_performance]})

  end


  def bd_gois

      @designs = BcDesign.includes({:fpu => [:part_performance], :cds => [:part_performance]})


#Design.includes({:promoter => [:part_performance, {:annotations => :annotation_type}], :fpu => [:part_performance, {:annotations => :annotation_type}]}).limit(@limit).offset(@offset)

  end

  def randomized_bds

      @designs = RandomizedBd.includes({:plasmid => [:part_performance]})

  end

  def get_plasmid_json

    plasmid = Part.find(params['design_id'])

    render :text => {
      :name => plasmid.biofab_id,
      :sequence => plasmid.sequence,
      :features => plasmid.annotations_for_flash_widgets
    }.to_json

  end

  def characterized_bds

    designs = Design.includes({:fpu => [:part_performance]})

    @fpus = []
    
    designs.each do |design|
      next if @fpus.index(design.fpu)
      @fpus << design.fpu
    end

    @fpus.sort! do |a, b|
      -a.part_performance.performance <=> -b.part_performance.performance
    end


  end

  def promoters

    designs = Design.includes({:promoter => [:part_performance]})

    @promoters = []
    
    designs.each do |design|
      next if @promoters.index(design.promoter)
      @promoters << design.promoter
    end

    @promoters.sort! do |a, b|
      -a.part_performance.performance <=> -b.part_performance.performance
    end

  end

end
