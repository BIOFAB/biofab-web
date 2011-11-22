class PlateLayoutController < ApplicationController

  def list
    if !current_user
      flash[:notice] = 'Please log in'
      redirect_to '/login'
      return
    end
    @mine = PlateLayout.where(["user_id = ?", current_user.id]).order('created_at desc')

   @others = PlateLayout.where(["user_id != ? or user_id IS NULL", current_user.id]).order('created_at desc')

  end

  def analyze2

    plate_layout = PlateLayout.find(params['id'])

    replicate_dirs = []

    dir = Dir.new(params['path'])
    dir.each do |replicate_entry|
      next if (replicate_entry == '.') || (replicate_entry == '..')
      replicate_entry_path = File.join(params['path'], replicate_entry)
      next if !File.directory?(replicate_entry_path)
      replicate_dirs << replicate_entry_path
    end

    plate_layout.delay.analyze_replicate_dirs(replicate_dirs, current_user)
    
    render :text => 'queued job'
  end

  def analyze
    plate_layout = PlateLayout.find(params['id'])
    if params['channel'] == 'red'
      fluo_channel = 'RED'
    elsif params['channel'] == 'green'
      fluo_channel = 'GRN'
    end

    Plate.delay.analyze(plate_layout, fluo_channel, current_user, params['dirname'])

    flash[:notice] = "The flow cytometer data is being analyzed. You will receive an email at #{current_user.email} when it is complete. When the analysis completes, the new plates will appear under the \"Plates using this layout\" section"
    redirect_to :action => 'data', :id => params['id']
  end

  def data

    @layout = PlateLayout.find(params['id'])

    if !@layout
      flash[:notice] = "The plate layout with id #{params['id']} does not exist."
      redirect_to :action => 'list'
      return
    end

    @dirs = PlateLayout.list_valid_fcs_dirs



  end

  def show

    # TODO should maybe get this from db somehow
    @field_names = ['organism',
                    'promoter',
                    'five_prime_utr',
                    'cds',
                    'terminator',
                    'channel']

    @placeholder_names = ['Organism',
                          'Promoter',
                          "5' UTR",
                          'CDS',
                          'Terminator',
                          'Channel']
                        

    if params['id']
      @layout = PlateLayout.find(params['id'])
    else
      @layout = PlateLayout.new
    end

    @promoter_descriptors = Part.promoter_descriptors
    @five_prime_utr_descriptors = Part.five_prime_utr_descriptors
    @cds_descriptors = Part.cds_descriptors
    @terminator_descriptors = Part.terminator_descriptors
    @organism_descriptors = Organism.descriptors

    # TODO should be in database
    @channel_descriptors = ['GRN', 'RED', 'ALL', 'NONE']
  end

  def save

    if params['id']
      layout = PlateLayout.find(params['id'])
      layout.attributes = params['plate_layout']
      old_wells = layout.wells.all
      layout.wells = []
    else
      layout = PlateLayout.new(params['plate_layout'])
    end

    if params['plate_layout']['hide_global_wells']
      layout.hide_global_wells = true
    else
      layout.hide_global_wells = false
    end

    if current_user
      layout.user = current_user
#      if current_user.current_project
#        layout.project = current_user.current_project
#      end
    end

    organism_parts = params['plate_layout_organism'].split(': ')
    if organism_parts.length == 2
      species, strain = organism_parts
      layout.organism = Organism.where(["species = ? AND strain = ?", species, strain]).first
    elsif organism_parts.length == 3
      species, strain, substrain = organism_parts
      layout.organism = Organism.where(["species = ? AND strain = ? AND substrain = ?", species, strain, substrain]).first
    end


    layout.channel = params['plate_layout_channel']

    layout.eou = Eou.new
    layout.eou.promoter = Part.find_by_biofab_id(params['plate_layout_eou']['promoter'].split(': ')[0])
    layout.eou.five_prime_utr = Part.find_by_biofab_id(params['plate_layout_eou']['five_prime_utr'].split(': ')[0])
    layout.eou.cds = Part.find_by_biofab_id(params['plate_layout_eou']['cds'].split(': ')[0])
    layout.eou.terminator = Part.find_by_biofab_id(params['plate_layout_eou']['terminator'].split(': ')[0])

    data = params['data']
    data.each_pair do |row, v1|
      v1.each_pair do |col, v2|

        well = PlateLayoutWell.new
        well.row = row
        well.column = col
        well.eou = Eou.new
        num_part_types_added = 0 # number of part types added for this well so far
        
        v2.each_pair do |part_type, descriptor|
          next if descriptor == ''
          
          if part_type == 'organism'
            organism_parts = descriptor.split(': ')
            if organism_parts.length == 2
              species, strain = organism_parts
              well.organism = Organism.where(["species = ? AND strain = ?", species, strain]).first
            elsif organism_parts.length == 3
              species, strain, substrain = organism_parts
              well.organism = Organism.where(["species = ? AND strain = ? AND substrain = ?", species, strain, substrain]).first
            end


          elsif part_type == 'channel'
            well.channel = descriptor
          else
            biofab_id, desc = descriptor.split(': ')
            part = Part.where(["biofab_id = ?", biofab_id]).includes(:part_type).first
            if part.part_type.name == 'Promoter'
              well.eou.promoter = part
            elsif part.part_type.name == "5' UTR"
              well.eou.five_prime_utr = part
            elsif part.part_type.name == 'CDS'
              well.eou.cds = part
            elsif part.part_type.name == 'Terminator'
              well.eou.terminator = part
            end
          end
          num_part_types_added += 1
        end
        if num_part_types_added > 0
          layout.wells << well
        end
      end
    end
   
    if layout.save
      if old_wells
        old_wells.each do |well|
          well.delete
        end
     end
      redirect_to :action => 'show', :id => layout.id
    else
      render :text => "Oh no... something bad happened. Error handling is really rather minimal for plate layouts right now. Sorry about that."
      return
    end
  end

end
