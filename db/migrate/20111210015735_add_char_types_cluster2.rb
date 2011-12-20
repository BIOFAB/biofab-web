class AddCharTypesCluster2 < ActiveRecord::Migration
  def up
    ct = CharacterizationType.new
    ct.name = 'event_count_c2'
    ct.save!

    ct = CharacterizationType.new
    ct.name = 'mean_c2'
    ct.save!
  end

  def down
  end
end
