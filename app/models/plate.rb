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


  # TODO old code, this now happens in plate_layout.rb
  def self.analyze(plate_layout, fluo_channel, user, dirname)
    begin

      # TODO move path to settings.rb
      input_path = File.join(Rails.root, 'public', 'flow_cytometer_input_data')
      script_dir = File.join(Rails.root, 'r_scripts', 'fcs3_analysis')

      # Initialize R and load the r source file
      r = RSRuby.instance
      r.setwd(script_dir)

      # For better exception handling (needed for Exceptor module to work)
      r.source(File.join(script_dir, 'exceptor.r'))

      # Flow cytometer analysis script
      r.source(File.join(script_dir, 'fcs3_analysis.r'))

      # The current directory to process
      # This will have one subdir per replicate
      data_path = File.join(input_path, dirname)

      out_path = File.join(Rails.root, 'public', 'flow_cytometer_output', plate_layout.id.to_s)
      if !File.directory?(out_path)
        Dir.mkdir(out_path)
      end

#      f = File.new(File.join(Rails.root, 'foobar.out'))
#      data = eval(f.readlines.join(''))
#      f.close

      # TODO remove hard-coded "rectangle" gating
      data = Exceptor::call_r_func(r, r.run, out_path, data_path, :fluo => fluo_channel, :init_gate => "rectangle")

      if !data
        raise "No data returned from analysis"
      end

      if fluo_channel == 'RED'
        fluo_channel = 'RED2'
      end

      # TODO remove this debug code
      f = File.new(File.join(Rails.root, 'foobar.out'), 'w+')
      f.puts(data.inspect)
      f.close

      plate_names = self.scan_for_plates(data_path)

      # characterizations
      chars = []
      8.times do |row|
        chars[row] = []
        12.times do |col|
          chars[row][col] = []
        end
      end

      plate_names.each do |plate_name|
        if !data[plate_name]
          next
        end

        plate = Plate.new
        plate.name = plate_name
        plate.plate_layout = plate_layout

        # the raw data for the plate
        plate_data = data[plate_name]

        plate_data["mean.#{fluo_channel}.HLin"].each_index do |i|
          break if i > 95 # don't accept more than 96 wells

          mean = plate_data["mean.#{fluo_channel}.HLin"][i]
          sd = plate_data["sd.#{fluo_channel}.HLin"][i]

          col = (i % 12)
          row = (i / 12)

          well = PlateWell.new
          well.column = (col+1).to_s
          well.row = (row+1).to_s
          well.replicate = Replicate.new

          characterization = Characterization.new
          characterization.value = mean
          characterization.standard_deviation = sd

          chars[row][col] << characterization

          well.replicate.characterizations << characterization

          well.save!

          plate.wells << well
        end

        plate.description = fluo_channel

        plate.save!
      end

      summary_data = data['Summary']

      # Performances

      
      chars.each_index do |row|
        row_a = chars[row]
        row_a.each_index do |col|
          col_chars = row_a[col]
          perf = Performance.new
          col_chars.each do |char| # loop through the characterizations for the different replicates
            perf.characterizations << char
          end
          i = row * 12 + col
          perf.value = summary_data["mean.mean.#{fluo_channel}.HLin"][i]
          perf.standard_deviation = summary_data["sd.mean.#{fluo_channel}.HLin"][i]
          perf.save!
        end
      end
     
      ProcessMailer.flowcyte_completed(user, plate_layout.id).deliver

    rescue Exception => e
      ProcessMailer.error(user, e, data_path).deliver
    end
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
    DataFile.joins(:plate_wells => :plate).where(["plates.id = ? AND data_files.type_name = ?", id, type_name])
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

    #init_gate = 'ellipse'
    init_gate = 'rectangle'
    
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
    
    plate = Plate.new
    plate.plate_layout = self
    plate.name = self.name # TODO what would be a good name?

    # create wells and characterizations based on analysis data
    plate.create_wells_from_r_data(data_set)

    plate.save!

    delete # delete self

    plate
  end


  def create_wells_from_r_data(data_set)

    data_set.each_pair do |input_file_path, data|

      create_well_from_r_data(input_file_path, data)

    end
  end

  def create_well_from_r_data(input_file_path, data, well=nil)
      if !data || !data['error'].blank?
        return nil
      end

      if !well        
        well = PlateWell.new
        self.wells << well
      else
        well.files = []
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

      # TODO unpretty
      c = Characterization.new_with_type('events')
      c.value = 0.0
      c.fluo_channel = data['fluo_channel']
      c.description = data['events']
      well.replicate.characterizations << c
      
      well.save!
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
    var_sheet = xls_add_plate_sheet(workbook, 'Variance')

    wells.each do |well|
      next if (well.row == 0) || (well.column == 0)
      characterization = well.replicate.characterization_with_type_name('mean')
      next if !characterization

      perf = characterization.performance_with_type_name('mean_of_means')
      value_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      perf = characterization.performance_with_type_name('standard_deviation_of_means')
      sd_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

      perf = characterization.performance_with_type_name('variance_of_means')
      var_sheet[well.row.to_i, well.column.to_i] = (perf && !perf.value.blank?) ? perf.value : ''

    end

    out_path = File.join(Rails.root, 'public', "plate_#{id}_performance.xls")
    workbook.write(out_path)
    out_path
  end


end
