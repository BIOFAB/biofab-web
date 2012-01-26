# a large, properly formatted, data file
class DataFile < ActiveRecord::Base
  
  after_destroy :delete_file

  has_and_belongs_to_many :plate_wells

  def self.sanitize_filename(filename)
    filename = File.basename(filename) 
    filename.gsub(/[^\w\.\_]/,'_') 
  end

  def self.from_local_file(file_path, type_name)
    require 'fileutils'

    file = self.new
    file.filename = self.sanitize_filename(File.basename(file_path))
    file.type_name = type_name
    file.save!
    Dir.mkdir(File.dirname(file.absolute_filepath))    
    FileUtils.copy(file_path, file.absolute_filepath)
    file.save! # TODO fix double save
    file
  end

  # no really, destroying orphans is a good thing!
  def self.destroy_orphans
    files = self.includes(:plate_wells).all
    deleted_files = []
    files.each do |file|
      if !file.plate_wells || (file.plate_wells.length == 0) 
        deleted_files << file
        file.destroy
      end
    end
    deleted_files
  end

  # delete files that no longer have a corresponding entry in the database
  def self.delete_lost_files
    require 'fileutils'

    dfile_path = File.join(Rails.root, 'public', Settings['data_files_path'])
    dirs = Dir.entries(dfile_path)
    deleted = []
    dirs.each do |dir|
      next if dir == '.'
      next if dir == '..'
      abs_dir = File.join(dfile_path, dir)
      next unless File.directory?(abs_dir)
      dfile_id = dir.to_i
      puts "looking for #{dfile_id}"
      dfile = self.find(dfile_id)
      if !dfile
        puts " -- not found: deleting"
        FileUtils.rmtree(abs_dir)
        deleted << abs_dir
      end
    end
    deleted
  end
  
  def absolute_filepath
    base_path = File.join(Rails.root, 'public', Settings['data_files_path'])
    File.expand_path(File.join(base_path, self.id.to_s, self.filename))
  end
  

  def filepath
    '/'+[Settings['data_files_path'], self.id.to_s, self.filename].join('/')
  end


  def delete_file
    FileUtils.rmtree(File.dirname(absolute_filepath))
  end


  
end
