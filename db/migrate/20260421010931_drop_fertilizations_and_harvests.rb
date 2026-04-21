class DropFertilizationsAndHarvests < ActiveRecord::Migration[8.1]
  def change
    drop_table :fertilizations
    drop_table :harvests
  end
end
