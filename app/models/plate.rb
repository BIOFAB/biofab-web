class Plate < ActiveRecord::Base
  has_many :wells, :class_name => 'PlateWell', :dependent => :destroy
  belongs_to :plate_layout

  def self.foo()
    # TODO move path to settings.rb
    input_path = File.join(Rails.root, 'public', 'flow_cytometer_input_data')
    script_dir = File.join(Rails.root, 'r_scripts', 'fcs3_analysis')

    # Initialize R and load the r source file
    r = RSRuby.instance
    r.setwd(script_dir)
    r.source(File.join(script_dir, 'foo.r'))
    
    data = r.foo()
    data
  end

  def self.scan_for_plates(path)
    puts path
    plate_names = []
    dir = Dir.new(path)
    dir.each do |entry|
      next if (entry == '.') || (entry == '..')
      plate_path = File.join(path, entry)
      next if !File.directory?(plate_path)
      puts "i have an entry: #{entry}"

      plate_dir = Dir.new(plate_path)
      plate_dir.each do |replicate_entry|
        next if (replicate_entry == '.') || (replicate_entry == '..')        
        replicate_path = File.join(plate_path, replicate_entry)
        next if !File.file?(replicate_path)

        puts "i have a replicate_entry: #{replicate_entry}"

        if replicate_entry.match(/\.fcs3?$/)
          plate_names << entry
          break
        end
        
      end
    end
    plate_names
  end

  def well_at(row, col)
    wells.where(["row = ? AND column = ?", row.to_s, col.to_s]).first
  end


  def well_characterization(row, col, characterization_type)
    well = wells.where(["row = ? AND column = ?", row.to_s, col.to_s]).first
    if !well || !well.replicate
      return nil
    end
    return well.replicate.characterization_with_type_name(characterization_type)
  end

  # get all of the data files associated with all plate wells,
  # that have a specific type_name (e.g. all plots)
  def well_files_by_type_name(type_name)
    data_files = DataFile.joins(:plate_wells => :plate).where(["plates.id = ? AND data_files.type_name = ?", id, type_name])
    data_files.collect {|dfile| dfile.absolute_filepath}
  end

  # re-do the flow cytometer analysis based on the plate layout and the original fcs files
  # this will only give a new result if either:
  #   The plate layout has changed
  #   or the R script has changed
  #   or the analyze_replicate_dir method has changed
  def re_analyze
    require 'tmpdir'
    
    r = RSRuby.instance
    
    script_path = File.join(Rails.root, 'r_scripts', 'fcs-analysis', 'r_scripts')
    main_script = File.join(script_path, 'fcs3_analysis.r')
    
    out_dir = Dir.mktmpdir('biofab_fcs')
    
    dump_file = File.join(Rails.root, 'out.dump')
    
    # fluo = 'RED'
    fluo = 'GRN' # fallback fluo if not defined for channel

    init_gate = Settings['fcs_analysis_gate_type']
    
    # retrieve the set of original fcs files for this plate
    fcs_file_paths = well_files_by_type_name('original_fcs_file')
        
    # retrieve the fluorescence channels for each well from the plate layout
    well_channels = plate_layout.get_well_channels

    r.setwd(script_path)
    r.source(main_script)

    data_set = Exceptor.call_r_func(r, r.batch, out_dir, fcs_file_paths, :fluo_channel => fluo, :well_channels => well_channels, :init_gate => init_gate, :verbose => true, :min_cells => 100)
    
    # TODO remove this debug code
    f = File.new(dump_file, 'w+')
    f.puts(data_set.inspect)
    f.close

    puts "deleting old data_file objects"
    old_files = []
    # delete the old wells
    wells.each do |well|
#      puts "#{well.name} - files: #{well.files.length}"
      old_files_well = well.delete_but_keep_files
#      puts "  old_files: #{old_files_well.length}"
#      puts " "
      old_files += old_files_well
    end

    puts "creating wells from R data"

    # create wells and characterizations based on analysis data
    create_wells_from_r_data(data_set)

    if old_files.length == 0
      raise "no old files"
    end

    puts "deleting old files"

    # delete the old files (they have now been copied for the new wells)
    old_files.each do |file|
      file.delete_file # delete the actual filesystem file
      file.delete # delete the database entry
    end

    puts "saving plate"

    save!
  end


  def create_wells_from_r_data(data_set)

    data_set.each_pair do |input_file_path, data|

      create_well_from_r_data(input_file_path, data)

    end
  end

  def create_well_from_r_data(input_file_path, data, well=nil)
    if !data
      return nil
    end
    
    if !well        
      well = PlateWell.new
      self.wells << well
    else
      if data['error'].blank?
        well.files = []
      end
    end
    
    if data['error'].blank?
      

    end


    original_fcs_file = DataFile.from_local_file(input_file_path, 'original_fcs_file')
    well.files << original_fcs_file
    
    plot_file = DataFile.from_local_file(data['outfile_plot'], 'plot')
    well.files << plot_file
    
    cleaned_fcs_file = DataFile.from_local_file(data['outfile_fcs'], 'cleaned_fcs_file')
    well.files << cleaned_fcs_file
    
    well.row, well.column = PlateWell.well_name_to_row_col(data['well_name'])
    well.replicate = Replicate.new
    
    c = Characterization.new_with_type('mean')
    c.value = data['mean']
    c.fluo_channel = data['fluo_channel']
    well.replicate.characterizations << c
    
    c = Characterization.new_with_type('standard_deviation')
    c.value = data['standard_deviation']
    c.fluo_channel = data['fluo_channel']
    well.replicate.characterizations << c
    
    c = Characterization.new_with_type('variance')
    c.value = data['variance']
    c.fluo_channel = data['fluo_channel']
    well.replicate.characterizations << c
    
    c = Characterization.new_with_type('event_count')
    c.value = data['num_events']
    c.fluo_channel = data['fluo_channel']
    well.replicate.characterizations << c
    
    c = Characterization.new_with_type('cluster_count')
    c.value = data['num_clusters']
    c.fluo_channel = data['fluo_channel']
    well.replicate.characterizations << c
    
    # TODO we probably shouldn't be saving the raw events to the DB
    c = Characterization.new_with_type('events')
    c.value = 0.0
    c.fluo_channel = data['fluo_channel']
    c.description = data['events']
    well.replicate.characterizations << c

    # second cluster info
    
    if data['num_events_c2']
      c = Characterization.new_with_type('event_count_c2')
      c.value = data['num_events_c2']
      c.fluo_channel = data['fluo_channel']
      well.replicate.characterizations << c
    end

    if data['mean_c2']
      c = Characterization.new_with_type('mean_c2')
      c.value = data['mean_c2']
      c.fluo_channel = data['fluo_channel']
      well.replicate.characterizations << c
    end
    
    well.save!
  end


  # TODO XXX duplicated in plate_layout.rb
  # should be called from there
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

  # TODO XXX duplicated in plate_layout.rb
  # should be called from there
  def xls_add_plate_layout_sheet(workbook)
    sheet = xls_add_plate_sheet(workbook, 'Plate layout', 1, 1)
    1.upto(8) do |row|
      sheet[row+1, 0] = plate_layout.well_descriptor_at(row, 0)
      1.upto(12) do |col|
        if row == 1
          sheet[0, col] = plate_layout.well_descriptor_at(0, col)
        end
        sheet[row+1, col+1] = plate_layout.brief_well_descriptor_at(row, col, :hide_NA => true)
      end
    end
    if plate_layout.organism
      sheet[12, 1] = "Plate-global organism:"
      sheet[12, 3] = plate_layout.organism.descriptor
    end
    if plate_layout.eou
      sheet[14, 1] = "Plate-global EOU:"
      sheet[14, 3] = plate_layout.eou.descriptor
    end
    sheet
  end

  def get_characterization_xls
    workbook = Spreadsheet::Workbook.new

    layout_sheet = xls_add_plate_layout_sheet(workbook)
    value_sheet = xls_add_plate_sheet(workbook, 'Characterization')
    sd_sheet = xls_add_plate_sheet(workbook, 'Standard deviation')
    var_sheet = xls_add_plate_sheet(workbook, 'Variance')

    wells.each do |well|
      value_sheet[well.row.to_i, well.column.to_i] = well.replicate.characterization_with_type_name('mean').value
      sd_sheet[well.row.to_i, well.column.to_i] = well.replicate.characterization_with_type_name('standard_deviation').value
      var_sheet[well.row.to_i, well.column.to_i] = well.replicate.characterization_with_type_name('variance').value
    end

    out_path = File.join(Rails.root, 'public', "plate_#{id}_characterization.xls")
    workbook.write(out_path)
    out_path
  end

  def get_performance_xls
    workbook = Spreadsheet::Workbook.new

    layout_sheet = xls_add_plate_layout_sheet(workbook)
    value_sheet = xls_add_plate_sheet(workbook, 'Performance')
    sd_sheet = xls_add_plate_sheet(workbook, 'Standard deviation')
    var_means_sheet = xls_add_plate_sheet(workbook, 'Variance of means')
    mean_vars_sheet = xls_add_plate_sheet(workbook, 'Mean of variances')
    total_var_sheet = xls_add_plate_sheet(workbook, 'Total variances')

    wells.each do |well|
      next if (well.row == 0) || (well.column == 0)
      characterization = well.replicate.characterization_with_type_name('mean')
      next if !characterization

      perf = characterization.performance_with_type_name('mean_of_means')
      value_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      perf = characterization.performance_with_type_name('standard_deviation_of_means')
      sd_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      perf = characterization.performance_with_type_name('variance_of_means')
      var_means_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      characterization = well.replicate.characterization_with_type_name('variance')
      next if !characterization

      perf = characterization.performance_with_type_name('mean_of_variances')
      mean_vars_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      perf = characterization.performance_with_type_name('total_variance')
      total_var_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

    end

    out_path = File.join(Rails.root, 'public', "plate_#{id}_performance.xls")
    workbook.write(out_path)
    out_path
  end


end
