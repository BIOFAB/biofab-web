class AddCharacterizationTypeError < ActiveRecord::Migration
  def up
    ct = CharacterizationType.new
    ct.name = 'error'
    ct.save!
  end

  def down
  end
end
