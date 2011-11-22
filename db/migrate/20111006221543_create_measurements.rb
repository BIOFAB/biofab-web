class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.integer :characterization_id
      t.integer :measurement_type_id
      t.float :value
      t.datetime :measured_at

      t.timestamps
    end
  end
end
