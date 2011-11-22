class RenameEouGeneCds < ActiveRecord::Migration
  def up
    rename_column :eous, :gene_id, :cds_id
  end

  def down
  end
end
