class ChangeGrowingConditionsToJsonOnPresets < ActiveRecord::Migration[8.1]
  def up
    remove_column :presets, :growing_conditions
    add_column :presets, :growing_conditions, :json
  end

  def down
    remove_column :presets, :growing_conditions
    add_column :presets, :growing_conditions, :text
  end
end
