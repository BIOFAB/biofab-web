class CreatePlasmidInfos < ActiveRecord::Migration
  def change
    create_table :plasmid_infos do |t|
      t.integer :eou_id
      t.integer :integration_index
      t.string :before_sequence
      t.string :after_sequence

      t.timestamps
    end
  end
end
