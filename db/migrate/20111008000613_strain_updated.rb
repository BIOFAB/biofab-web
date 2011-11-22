class StrainUpdated < ActiveRecord::Migration
  def up
    remove_column :strains, :eou_id
    add_column :strains, :chromosomal_integration_index, :integer
    add_column :strains, :before_sequence, :string
    add_column :strains, :after_sequence, :string
    add_column :strains, :location_path, :string
  end

  def down
  end
end
