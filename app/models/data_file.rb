# a large, properly formatted, data file
class DataFile < ActiveRecord::Base
  
  after_destroy :delete_file

  has_and_belongs_to_many :plate_wells

#  def self.from_data(data, filename)
#    @filename = sanitize_filename(filename)
#    if !File.exists?(File.dirname(path_to_file))
#      Dir.mkdir(File.dirname(path_to_file))
#    end    
#    File.open(self.path_to_file, "wb") { |f| f.write(data) }
#  end

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
