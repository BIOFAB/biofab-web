class CreateReliabilities < ActiveRecord::Migration
  def change
    create_table :reliabilities do |t|
      t.integer :type_id
      t.integer :part_id
      t.float :value
      t.float :standard_deviation
      t.text :description

      t.timestamps
    end

    create_table "performances_reliabilities", :id => false, :force => true do |t|
      t.integer "reliability_id"
      t.integer "performance_id"
    end


  end
end
