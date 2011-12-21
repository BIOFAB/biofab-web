class PlateWell < ActiveRecord::Base
  belongs_to :plate
  belongs_to :replicate
  has_and_belongs_to_many :files, :class_name => 'DataFile'


  def delete_but_keep_files
    old_files = []
    files.each do |file|
      old_files << file
    end
    if replicate
      replicate.delete_completely
    end
    self.files = []
    delete

    old_files
  end

  # returns a name like C03
  def name
    return nil if column.blank? || row.blank? || (column.to_i <= 0) || (row.to_i <= 0)
    row_name = (?A..?Z).to_a[(row.to_i)-1].chr
    col_name = (column.to_i < 10) ? '0'+column.to_s : column.to_s
    return row_name+col_name    
  end

  def self.well_name_to_row_col(well_name)
    row_name = well_name[0..0].upcase
    col_name = well_name[1..2]

    row = row_name[0] - ?A + 1
    col = col_name.to_i
    return [row, col]
  end

  def file_by_type(type_name)
    files.where(["type_name = ?", type_name]).first
  end


  # get the corresponding well from the plate layout
  def plate_layout_well
    plate.plate_layout.well_at(row, column)
  end

  def re_analyze

    require 'tmpdir'
    
    r = RSRuby.instance
    
    script_path = File.join(Rails.root, 'r_scripts', 'fcs-analysis', 'r_scripts')
    main_script = File.join(script_path, 'fcs3_analysis.r')
    out_dir = Dir.mktmpdir('biofab_fcs')
    dump_file = File.join(Rails.root, 'out.dump')
    
    init_gate = Settings['fcs_analysis_gate_type']
    
    # get file path for the original, unprocessed fcs file
    fcs_file_path = files.find_by_type_name('original_fcs_file').absolute_filepath
        
    # retrieve the fluorescence channels for each well from the plate layout
#    well_channels = plate_layout.get_well_channels
    fluo_channel = plate_layout_well.channel

    r.setwd(script_path)
    r.source(main_script)

    out_plot_path = File.join(out_dir, 'plot.svg')
    output_filename = 'c1.fcs'
    output_filename_cluster2 = 'c2.fcs'
 
    data = Exceptor.call_r_func(r, r.run, out_dir, out_plot_path, fcs_file_path, :fluo_channel => fluo_channel, :init_gate => init_gate, :output_filename => output_filename, :output_filename_cluster2 => output_filename_cluster2, :verbose => true, :min_cells => 100)
    
    # TODO remove this debug code
    f = File.new(dump_file, 'w+')
    f.puts(data.inspect)
    f.close
    
    # create well and characterizations based on analysis data
    plate.create_well_from_r_data(fcs_file_path, data, self)
    self
  end

end
