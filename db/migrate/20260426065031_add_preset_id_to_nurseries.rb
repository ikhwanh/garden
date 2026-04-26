class AddPresetIdToNurseries < ActiveRecord::Migration[8.1]
  def change
    add_column :nurseries, :preset_id, :integer
    add_index :nurseries, :preset_id
    add_foreign_key :nurseries, :presets
  end
end
