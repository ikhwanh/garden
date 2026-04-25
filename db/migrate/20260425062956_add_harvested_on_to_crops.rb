class AddHarvestedOnToCrops < ActiveRecord::Migration[8.1]
  def change
    add_column :crops, :harvested_on, :date
  end
end
