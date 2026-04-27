# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :presets do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :local_name
      t.string :grow_type, null: false
      t.integer :days_to_harvest_min
      t.integer :days_to_harvest_max
      t.json :preset_data, null: false, default: {}
      t.timestamps
    end
    add_index :presets, :slug, unique: true

    create_table :nurseries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :started_on
      t.date :transplanted_on
      t.integer :quantity_initial
      t.integer :quantity_final
      t.text :note
      t.integer :preset_id
      t.timestamps
    end
    add_index :nurseries, :preset_id
    add_foreign_key :nurseries, :presets

    create_table :crops do |t|
      t.references :user, null: false, foreign_key: true
      t.references :nursery, null: true, foreign_key: true
      t.integer :preset_id
      t.string :name, null: false
      t.date :planted_on, null: false
      t.integer :quantity_initial
      t.integer :quantity_final
      t.text :note
      t.date :harvested_on
      t.date :expected_harvest_on
      t.timestamps
    end

    create_table :reminders do |t|
      t.references :crop, null: false, foreign_key: true
      t.string :category, null: false
      t.string :phase, null: false
      t.date :due_on, null: false
      t.json :details, null: false, default: {}
      t.datetime :notified_at
      t.timestamps
    end
    add_index :reminders, [ :crop_id, :due_on ]

    create_table :cashflow_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :entry_type
      t.bigint :amount
      t.string :description
      t.date :occurred_on
      t.string :cost_type
      t.string :category
      t.timestamps
    end
  end
end
