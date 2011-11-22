class CreateReliabilityTypes < ActiveRecord::Migration
  def change
    create_table :reliability_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
