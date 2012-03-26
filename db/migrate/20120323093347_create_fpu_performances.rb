class CreateFpuPerformances < ActiveRecord::Migration
  def change
    create_table :fpu_performances do |t|
      t.integer :part_id
      t.string :name
      t.float :goi_average
      t.float :goi_sd

      t.timestamps
    end
  end
end
