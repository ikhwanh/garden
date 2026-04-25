class AddExpectedHarvestOnToCrops < ActiveRecord::Migration[8.1]
  def change
    add_column :crops, :expected_harvest_on, :date
  end
end
