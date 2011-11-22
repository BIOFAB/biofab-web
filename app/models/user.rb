class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_and_belongs_to_many :projects

  attr_accessible :email, :password, :password_confirmation

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email


#  def foowriter
#    sleep(20)
#    f = File.new("/tmp/foo.txt", "w+")
#    f.puts "Now: #{Time.now}"
#    f.close
#  end

end
