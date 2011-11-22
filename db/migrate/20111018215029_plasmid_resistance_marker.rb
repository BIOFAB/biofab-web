class PlasmidResistanceMarker < ActiveRecord::Migration
  def up
    add_column :plasmid_infos, :resistance_markers, :string
  end

  def down
  end
end
