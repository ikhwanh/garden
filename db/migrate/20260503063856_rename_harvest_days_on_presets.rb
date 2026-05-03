class RenameHarvestDaysOnPresets < ActiveRecord::Migration[8.1]
  def change
    rename_column :presets, :days_to_harvest_min, :days_min
    rename_column :presets, :days_to_harvest_max, :days_max
  end
end
