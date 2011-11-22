class CreateFeatureSets < ActiveRecord::Migration
  def change
    create_table :feature_sets do |t|
      t.string :name

      t.timestamps
    end
    create_table :feature_set_features do |t|
      t.integer :feature_id
      t.integer :feature_set_id
    end
  end
end
