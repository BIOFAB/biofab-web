class CreateCharacterizationTypes < ActiveRecord::Migration
  def change
    create_table :characterization_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
