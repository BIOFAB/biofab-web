class StrainStuff < ActiveRecord::Migration
  def up
    add_column :strains, :old_location, :string
    add_column :strains, :frozen_date, :datetime
    add_column :strains, :frozen_by, :string
  end

  def down
  end
end
