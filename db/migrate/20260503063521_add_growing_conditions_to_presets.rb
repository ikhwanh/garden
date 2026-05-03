class AddGrowingConditionsToPresets < ActiveRecord::Migration[8.1]
  def change
    add_column :presets, :growing_conditions, :text
  end
end
