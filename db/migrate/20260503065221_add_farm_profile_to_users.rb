class AddFarmProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :altitude_masl, :integer
    add_column :users, :avg_temp_c, :decimal
    add_column :users, :avg_humidity_pct, :decimal
  end
end
