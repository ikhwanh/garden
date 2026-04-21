class CreatePresets < ActiveRecord::Migration[8.1]
  def change
    create_table :presets do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :local_name
      t.string :grow_type, null: false
      t.integer :days_to_harvest_min
      t.integer :days_to_harvest_max
      t.jsonb :preset_data, null: false, default: {}

      t.timestamps
    end

    add_index :presets, :slug, unique: true
  end
end
