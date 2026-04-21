class AddPresetIdToPlants < ActiveRecord::Migration[8.1]
  def change
    add_column :plants, :preset_id, :integer
  end
end
