class AddDataFiles < ActiveRecord::Migration
  def up
    create_table "data_files", :force => true do |t|
      t.string   "content_type"
      t.string   "filepath"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "data_file_set_id"
    end
  end

  def down
  end
end
