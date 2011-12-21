class PlateLayout < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :eou
  belongs_to :organism
  has_many :wells, :class_name => 'PlateLayoutWell', :dependent => :destroy
  has_many :plates

  def self.re_calculate_performances(layout, user)
    begin

      puts "re-calculating performances"

      layout.re_calculate_performances

      ProcessMailer.performance_calculations_completed(user, layout.id).deliver

    rescue Exception => e
      puts "exception encountered... email being sent"
      ProcessMailer.error(user, e).deliver
    end
  end

  def self.re_analyze_plates(layout, user)
    begin

      puts "re-analyzing plates"

      layout.re_analyze_plates

      puts "re-calculating performances"

      layout.re_calculate_performances

      ProcessMailer.flowcyte_completed(user, layout.id).deliver

    rescue Exception => e
      puts "exception encountered... email being sent"
      ProcessMailer.error(user, e).deliver
    end
  end

  def analyze_replicate_dirs(replicate_dirs, user)
    begin
      plates = []
      cur_rep_dir = ''
      replicate_dirs.each do |rep_dir|
        cur_rep_dir = rep_dir
        plates << self.analyze_replicate_dir(rep_dir, user)
      end

      improve_cluster_selection

      calculate_performances

      ProcessMailer.flowcyte_completed(user, self.id).deliver
      
    rescue Exception => e
      
      ProcessMailer.error(user, e, cur_rep_dir).deliver

    end
  end

  # for replicates with bi-modal results
  # cluster selection is improved by comparing
  # with other replicates and checking if
  # it could be caused by contamination by surrounding wells
  def improve_cluster_selection

    # for each well in the plate layout, find all plate wells
    wells.each do |layout_well|

      replicates = Replicate.joins(:plate_wells => :plate).where(["plate_wells.row = ? AND plate_wells.column = ? AND plates.plate_layout_id = ?", layout_well.row, layout_well.column, id]).all

      if replicates.length <= 0
        next
      end

      bi_modals = [] # bi-modal replicates
      mono_modals = [] # non-bi-modal replicates

      replicates.each do |replicate|
        num_clusters = replicate.characterization_with_type_name('cluster_count').value
        if num_clusters > 1
          bi_modals << replicate
        else
          mono_modals << replicate
        end
      end

      # my work here is done
      if bi_modals.length == 0
        next
      end

      # less than half of the replicates are bi-modal
      if bi_modals.length < (mono_modals.length / 2.0)

        mono_modal_means = mono_modals.collect do |replicate|
          replicate.characterization_with_type_name('mean').value
        end

        mean_of_means = StatisticsHelpers.mean(mono_modal_means)

        bi_modals.each do |replicate|
          mean_c1 = replicate.characterization_with_type_name('mean').value
          mean_c2 = replicate.characterization_with_type_name('mean_c2').value

          c1_mean_variance = StatisticsHelper.variance([mean_of_means, mean_c1])
          c2_mean_variance = StatisticsHelper.variance([mean_of_means, mean_c2])

          # check which cluster is closer to the mono-modal mean of means
          if c2_mean_variance < c1_mean_variance
            # TODO re-analyze while forcing cluster to as primary
          else
            # correct cluster was already selected. do nothing
          end
        end

      else # more than, or exactly, half of the replicates are bi-modal

        # TODO
        # Find means of all clusters 
        #   (e.g. 4 clusters total if there are 3 replicates and one is bi-modal).
        #
        # Find combination of means with lowest standard deviation of means.
        # 
        # Select the clusters from this combination.
 
      end
    end
  end

  # first delete all performances, then calculate them again
  def re_calculate_performances
    count = 1
    plates.each do |plate|
      puts "deleting old performances for plate number #{count}"
      count += 1
      plate.wells.each do |well|
        next if !well.replicate
        well.replicate.characterizations.each do |char|
          char.performances.each do |perf|
            perf.delete
          end
        end
      end
    end

    puts "all old performances deleted. now calculating new performances"
    calculate_performances
  end

  # calculate performances based on characterization data
  def calculate_performances

    perfs = []

    perfs << calculate_total_variance_performance

    char_type = 'mean'
    perf_type_name = 'variance_of_means'
    calc_method = :variance

    perfs << calculate_performance(char_type, perf_type_name, calc_method)
    
    char_type = 'mean'
    perf_type_name = 'standard_deviation_of_means'
    calc_method = :standard_deviation
    
    perfs << calculate_performance(char_type, perf_type_name, calc_method)
    
    char_type = 'mean'
    perf_type_name = 'mean_of_means'
    calc_method = :mean
    
    perfs << calculate_performance(char_type, perf_type_name, calc_method)
    
    char_type = 'variance'
    perf_type_name = 'mean_of_variances'
    calc_method = :mean
    
    perfs << calculate_performance(char_type, perf_type_name, calc_method)

    perfs
  end
  
  # calculate a performances for a specific type
  # e.g. char_type 'mean', perf_type_name 'variance_of_means' and calc_method :variance
  # will calculate the variance of means for this plate_layout based on the available plates (replicates)
  def calculate_performance(char_type, perf_type_name, calc_method)
    
    perf_type = PerformanceType.find_by_name(perf_type_name)
    return nil if !perf_type
    
    if !plates.first || !plates.first.wells.first
      next
    end
    
    performances = []

    wells.each do |ref_well|

      puts "---------------------------------------------------"
      puts "Calculating #{perf_type_name} for #{ref_well.name}"
      
      perf = Performance.new
      perf.performance_type = perf_type
      
      count = 1
      plates.each do |plate|
        puts "  For plate: #{plate.name} - #{count}"
        count += 1
        characterization = plate.well_characterization(ref_well.row, ref_well.column, char_type)
        if characterization
          puts "    Result: #{characterization.value}"
        else
          puts "    No result!"
        end
        next if !characterization
        perf.characterizations << characterization
      end
      
      puts "  = char count #{perf.characterizations.length}"

      # a performance needs at least one characterization for mean
      # and at least two for everything else
      if ((perf.characterizations.length < 1) && (calc_method == :mean)) || ((perf.characterizations.length < 2) && (calc_method != :mean))
        puts "skipped #{ref_well.row}.#{ref_well.column}"
        next
      end
      
      values = perf.characterizations.collect{|char| char.value}
      
      perf.value = StatisticsHelpers.send(calc_method, values)
      
      perf.save!
      
      performances << perf
    end
    performances
  end


  # special method for calculating the performances with the type 'total_variance'
  def calculate_total_variance_performance

    performances = []

    perf_type = PerformanceType.find_by_name('total_variance')
    return nil if !perf_type

    if !plates.first || !plates.first.wells.first
      next
    end

    wells.each do |ref_well|

      puts "---------------------------------------------------"
      puts "Calculating total_variance for #{ref_well.name}"

      perf = Performance.new
      perf.performance_type = perf_type

      means = []
      variances = []

      count = 1
      plates.each do |plate|
        puts "  For plate: #{plate.name} - #{count}"
        count += 1
        characterization = plate.well_characterization(ref_well.row, ref_well.column, 'mean')
        if characterization
          puts "    mean: #{characterization.value}"
        else
          puts "    No mean!"
        end
        next if !characterization
        perf.characterizations << characterization
        means << characterization.value
        characterization = plate.well_characterization(ref_well.row, ref_well.column, 'variance')
        if characterization
          puts "    variance: #{characterization.value}"
        else
          puts "    No variance!"
        end
        next if !characterization
        variances << characterization.value
        perf.characterizations << characterization
      end

      # a performance needs at least two characterizations for total variance
      if (means.length < 2) || (variances.length < 2)
        puts "skipped #{ref_well.row}.#{ref_well.column}"
        next
      end

      values = perf.characterizations.collect{|char| char.value}

      perf.value = StatisticsHelpers.variance(means) + StatisticsHelpers.mean(variances)

      perf.save!

      performances << perf
    end
    performances
  end


  # get a hash where the keys are the well names (e.g. B03)
  # and the values are the fluorescence channels (e.g. GRN or RED)
  # this is used to pass this association to the R analysis scripts
  def get_well_channels # (poor channels. get well soon!)
    well_channels = {}
    wells.each do |well|
      next if well.channel.blank?
      well_channels[well.name] = well.channel
    end
    well_channels
  end


  # re-run analysis for all plates
  # this will create new plates with new wells
  # and delete the old plates and their wells
  def re_analyze_plates
    plates.each do |plate|
      plate.re_analyze
    end
  end

  def analyze_replicate_dir(replicate_dir, user)

    require 'tmpdir'
    
    r = RSRuby.instance
    
    script_path = File.join(Rails.root, 'r_scripts', 'fcs-analysis', 'r_scripts')
    main_script = File.join(script_path, 'fcs3_analysis.r')
    
    out_dir = Dir.mktmpdir('biofab_fcs')
    
    dump_file = File.join(Rails.root, 'out.dump')
    
    # fluo = 'RED'
    fluo = 'GRN' # fallback fluo if not defined for channel

    init_gate = Settings['fcs_analysis_gate_type']
    
    fcs_file_paths = []
    
    dir = Dir.new(replicate_dir)
    dir.each do |fcs_file|
      next if (fcs_file == '.') || (fcs_file == '..')
      fcs_file_path = File.join(replicate_dir, fcs_file)
      next if File.directory?(fcs_file_path)
      fcs_file_paths << fcs_file_path
    end
    
    r.setwd(script_path)
    r.source(main_script)

    data_set = Exceptor.call_r_func(r, r.batch, out_dir, fcs_file_paths, :fluo_channel => fluo, :well_channels => get_well_channels, :init_gate => init_gate, :verbose => true, :min_cells => 100)
    
    # TODO remove this debug code
    f = File.new(dump_file, 'w+')
    f.puts(data_set.inspect)
    f.close
    
    plate = Plate.new
    plate.plate_layout = self
    plate.name = self.name # TODO what would be a good name?

    plate.create_wells_from_r_data(data_set)

    plate.save!

    plate
  end

  # re-analyze a specific well for all plates
  # and return re-analyzed wells
  def re_analyze_well(row, col)
    wells = []
    plates.each do |plate|
      wells << plate.well_at(row, col).re_analyze
    end
    wells.compact
  end


  # find dirs containing a dir for each replicate, each containing at least 96 fcs files
  def self.list_valid_fcs_dirs
    dirs = []
    if Settings['fcs_input_path_is_relative']
      outer_path = File.join(Rails.root, Settings['fcs_input_path'])
    else
      outer_path = Settings['fcs_input_path']
    end

    dir = Dir.new(outer_path)
    dir.each do |entry|
      next if (entry == '.') || (entry == '..')
      entry_path = File.join(outer_path, entry)
      next if !File.directory?(entry_path)

      subdir = Dir.new(entry_path)
      subdir_count = 0
      subdir.each do |subentry|
        next if (subentry == '.') || (subentry == '..')
        subentry_path = File.join(entry_path, subentry)
        next if !File.directory?(subentry_path)
        subsubdir = Dir.new(subentry_path)
        fcs_count = 0
        subsubdir.each do |subsubentry|
          next if (subsubentry == '.') || (subsubentry == '..')
          if subsubentry.match(/.*\.fcs$/)
            fcs_count += 1
          end
        end
        if (fcs_count >= 1) 
          subdir_count += 1
        end
      end
      if subdir_count > 0
        dirs << {
          :name => entry,
          :path => entry_path,
          :num_files => subdir_count,
          :created_at => File.ctime(subdir.path)
        }      
      end
    end
    dirs
  end

  def well_at(row, col)
    wells.where(["row = ? AND column = ?", row, col]).includes(:eou).first
  end

  def brief_well_descriptor_at(row, col, opts={})
    well = wells.where(["row = ? AND column = ?", row, col]).includes(:eou).first
    return 'NA' if !well
    desc = ''
    desc += "#{well.organism.brief_descriptor} | " if well.organism
    desc += well.eou.descriptor(opts) if well.eou
  end

  def well_descriptor_at(row, col, opts={})
    cur_organism = nil
    cur_eou = nil
    well = wells.where(["row = ? AND column = ?", row, col]).includes(:eou).first
    if !well # not directly specified
      well = wells.where(["row = ? AND column = 0", row]).includes(:eou).first
    end
    if !well # not specified by row
      well = wells.where(["row = 0 AND column = ?", col]).includes(:eou).first
    end
    if !well # not specified by column
      cur_organism = organism
      cur_eou = eou
    else
      cur_organism = well.organism
      cur_eou = well.eou
    end
    "#{(cur_organism) ? cur_organism.brief_descriptor : 'ORGANISM_NA'} | #{(cur_eou) ? cur_eou.descriptor(opts) : 'EOU_NA'}"
  end

  def well_descriptor_for(part_type_name, row, col)
    return '' if !id
    well = wells.where(["row = ? AND column = ?", row, col]).includes(:eou).first
    return '' if !well

    # TODO ugly
    if part_type_name == 'organism' 
      part = well.organism
      return '' if !part
      part.descriptor
    elsif part_type_name == 'channel'
      return '' if well.channel.blank?
      well.channel
    else
      part = well.eou.send(part_type_name)
      return '' if !part
      part.descriptor
    end

  end


  # TODO this could definitely be better
  def get_performance_xls
    workbook = Spreadsheet::Workbook.new

    layout_sheet = xls_add_plate_layout_sheet(workbook)
    value_sheet = xls_add_plate_sheet(workbook, 'Performance')
    sd_sheet = xls_add_plate_sheet(workbook, 'Standard deviation')
    var_means_sheet = xls_add_plate_sheet(workbook, 'Variance of means')
    mean_vars_sheet = xls_add_plate_sheet(workbook, 'Mean of variances')
    total_var_sheet = xls_add_plate_sheet(workbook, 'Total variances')


    # iterate over plate_layout wells
    wells.each do |well|
      next if (well.row == 0) || (well.column == 0)

      # find at least one corresponding plate_well that has a mean value
      characterization = nil
      plates.each do |plate|
        plate_well = plate.well_at(well.row, well.column)
        next if !plate_well
        characterization = plate_well.replicate.characterization_with_type_name('mean')
        break if characterization
      end

      if characterization # if at least one plate_well had a mean-value characterization 

        perf = characterization.performance_with_type_name('mean_of_means')
        value_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

        perf = characterization.performance_with_type_name('standard_deviation_of_means')
        sd_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

        perf = characterization.performance_with_type_name('variance_of_means')
        var_means_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      end

      # find at least one corresponding plate_well that has a variance value
      characterization = nil
      plates.each do |plate|
        plate_well = plate.well_at(well.row, well.column)
        next if !plate_well
        characterization = plate_well.replicate.characterization_with_type_name('variance')
        break if characterization
      end
      
      if characterization # if at least one plate_well had a variance-value characterization 
        
        perf = characterization.performance_with_type_name('mean_of_variances')
        mean_vars_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

        perf = characterization.performance_with_type_name('total_variance')
        total_var_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      end
    end

    out_path = File.join(Rails.root, 'public', "plate_layout_#{id}_performance.xls")
    workbook.write(out_path)
    out_path
  end


  def xls_add_plate_sheet(workbook, sheet_name, y_offset=0, x_offset=0)
    sheet = workbook.create_worksheet
    sheet.name = sheet_name

    row_name_format = Spreadsheet::Format.new(:weight => :bold)
    col_name_format = Spreadsheet::Format.new(:weight => :bold)

    # write row names
    8.times do |row|
      row_name = ((?A)+row).chr
      sheet[y_offset+row+1, x_offset] = row_name
      sheet.row(y_offset+row+1).set_format(x_offset, row_name_format)
    end

    # write column names
    12.times do |col|
      col_name = (col+1).to_s
      sheet[y_offset, x_offset+col+1] = col_name
      sheet.row(y_offset).set_format(x_offset+col+1, col_name_format)
    end
    sheet
  end



  def xls_add_plate_layout_sheet(workbook)
    sheet = xls_add_plate_sheet(workbook, 'Plate layout', 1, 1)
    1.upto(8) do |row|
      sheet[row+1, 0] = well_descriptor_at(row, 0)
      1.upto(12) do |col|
        if row == 1
          sheet[0, col] = well_descriptor_at(0, col)
        end
        sheet[row+1, col+1] = brief_well_descriptor_at(row, col, :hide_NA => true)
      end
    end
    if organism
      sheet[12, 1] = "Plate-global organism:"
      sheet[12, 3] = organism.descriptor
    end
    if eou
      sheet[14, 1] = "Plate-global EOU:"
      sheet[14, 3] = eou.descriptor
    end
    sheet
  end


end
