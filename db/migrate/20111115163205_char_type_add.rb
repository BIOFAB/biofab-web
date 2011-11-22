class CharTypeAdd < ActiveRecord::Migration
  def up
    ct = CharacterizationType.new
    ct.name = "events"
    ct.save!
  end

  def down
  end
end
