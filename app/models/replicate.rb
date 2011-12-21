class Replicate < ActiveRecord::Base
  belongs_to :strain
  has_many :characterizations
  has_many :plate_wells

  def characterization_with_type_name(type_name)
    characterizations.joins(:characterization_type).where(["characterization_types.name = ?", type_name]).first
  end

  def delete_completely
    characterizations.each do |char|
      char.delete
    end
  end

end
