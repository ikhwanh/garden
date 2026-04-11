class CreateSeeds < ActiveRecord::Migration[8.1]
  def change
    create_table :seeds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :germination_days
      t.date :started_at
      t.date :transplanted_at

      t.timestamps
    end
  end
end
