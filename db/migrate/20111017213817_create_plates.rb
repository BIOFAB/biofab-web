class CreatePlates < ActiveRecord::Migration
  def change
    create_table :plates do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
