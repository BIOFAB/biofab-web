class CreatePerformances < ActiveRecord::Migration
  def change
    create_table :performances do |t|
      t.integer :strain_id
      t.integer :performance_type_id
      t.float :value
      t.float :standard_deviation
      t.string :notes

      t.timestamps
    end

    create_table :performance_characterizations do |t|
      t.integer :performance_id
      t.integer :characterization_id
    end

  end
end
