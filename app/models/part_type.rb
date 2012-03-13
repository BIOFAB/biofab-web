class PartType < ActiveRecord::Base
  has_many :parts

  def to_s
    name
  end

end
