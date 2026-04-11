class CreateHarvests < ActiveRecord::Migration[8.1]
  def change
    create_table :harvests do |t|
      t.references :plant, null: false, foreign_key: true
      t.date :harvested_on, null: false
      t.decimal :weight_grams, precision: 8, scale: 2
      t.integer :quantity
      t.string :unit

      t.timestamps
    end
  end
end
