class RenameSeedsPlantsToNurseriesCrops < ActiveRecord::Migration[8.1]
  def change
    remove_column :seeds, :germination_days, :integer

    remove_column :plants, :grow_medium, :string
    remove_column :plants, :days_to_maturity, :integer
    remove_column :plants, :container_size, :string
    remove_column :plants, :location, :string

    rename_table :seeds, :nurseries
    rename_table :plants, :crops

    rename_column :crops, :seed_id, :nursery_id
    rename_column :reminders, :plant_id, :crop_id
  end
end
