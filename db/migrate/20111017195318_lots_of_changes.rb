class LotsOfChanges < ActiveRecord::Migration
  def up
    add_column :annotations, :parent_part_id, :integer

    rename_table :feature_sets, :collections
    create_table "collections_parts", :id => false, :force => true do |t|
      t.integer "collection_id"
      t.integer "part_id"
    end
    
    drop_table :feature_sets_features

    drop_table :features

    add_column :organisms, :sequence, :string

    add_column :parts, :plasmid_info_id, :integer

    drop_table :plasmids

  end

  def down
  end
end
