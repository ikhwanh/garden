class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.references :plant, null: false, foreign_key: true
      t.string :category, null: false
      t.string :phase, null: false
      t.date :due_on, null: false
      t.json :details, null: false, default: {}
      t.datetime :notified_at

      t.timestamps
    end

    add_index :reminders, [ :plant_id, :due_on ]
  end
end
