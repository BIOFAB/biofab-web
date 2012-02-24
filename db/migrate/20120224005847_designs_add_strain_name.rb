class DesignsAddStrainName < ActiveRecord::Migration
  def up
    add_column :designs, :strain_name, :string
  end

  def down
  end
end
