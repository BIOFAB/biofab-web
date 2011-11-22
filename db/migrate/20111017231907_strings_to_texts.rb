class StringsToTexts < ActiveRecord::Migration
  def up
    change_column :characterizations, :description, :text
    change_column :organisms, :sequence, :text
    change_column :parts, :sequence, :text
    change_column :parts, :description, :text
    change_column :plasmid_infos, :before_sequence, :text
    change_column :plasmid_infos, :after_sequence, :text
    change_column :plates, :description, :text
    change_column :replicates, :description, :text
    change_column :sequencings, :expected_sequence, :text


    remove_column :strains, :chromosomal_integration_index
    remove_column :strains, :before_sequence
    remove_column :strains, :after_sequence
  end

  def down
  end
end
