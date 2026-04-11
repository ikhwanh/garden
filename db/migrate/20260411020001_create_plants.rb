class CreatePlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :seed, null: false, foreign_key: true
      t.string :name, null: false
      t.string :container_size
      t.string :grow_medium, null: false
      t.string :location
      t.date :planted_on, null: false

      t.timestamps
    end
  end
end
