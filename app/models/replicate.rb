class Replicate < ActiveRecord::Base
  belongs_to :strain
  has_many :characterizations
  has_many :plate_wells

  def characterization_with_type_name(type_name)
    characterizations.joins(:characterization_type).where(["characterization_types.name = ?", type_name]).first
  end

  # TODO should probably be a view helper
  def characterization_value(type_name)
    char = characterization_with_type_name(type_name)
    return nil if !char
    char.value.round(2)
  end

  # TODO should probably be a view helper
  def characterization_description(type_name)
    char = characterization_with_type_name(type_name)
    return nil if !char
    char.description
  end

  def delete_completely
    characterizations.each do |char|
      char.delete
    end
  end

end
