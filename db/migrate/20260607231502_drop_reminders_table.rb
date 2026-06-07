class DropRemindersTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :reminders do |t|
      t.string "category", null: false
      t.datetime "created_at", null: false
      t.integer "crop_id", null: false
      t.json "details", default: {}, null: false
      t.date "due_on", null: false
      t.datetime "notified_at"
      t.string "phase", null: false
      t.datetime "updated_at", null: false
    end
  end
end
