class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|
      t.string :species
      t.string :strain
      t.string :substrain
      t.string :url
      t.string :location

      t.timestamps
    end
  end
end
