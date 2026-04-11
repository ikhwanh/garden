class CreateFertilizations < ActiveRecord::Migration[8.1]
  def change
    create_table :fertilizations do |t|
      t.references :plant, null: false, foreign_key: true
      t.string :fertilizer_type, null: false
      t.date :applied_on, null: false
      t.decimal :amount, precision: 8, scale: 2
      t.string :unit

      t.timestamps
    end
  end
end
