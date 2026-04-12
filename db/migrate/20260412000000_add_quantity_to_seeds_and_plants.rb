class AddQuantityToSeedsAndPlants < ActiveRecord::Migration[8.1]
  def change
    add_column :seeds, :quantity_initial, :integer
    add_column :seeds, :quantity_final, :integer
    add_column :plants, :quantity_initial, :integer
    add_column :plants, :quantity_final, :integer
  end
end
