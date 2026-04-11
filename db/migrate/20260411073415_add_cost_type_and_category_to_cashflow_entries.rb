class AddCostTypeAndCategoryToCashflowEntries < ActiveRecord::Migration[8.1]
  def change
    change_column :cashflow_entries, :amount, :bigint
    add_column :cashflow_entries, :cost_type, :string
    add_column :cashflow_entries, :category, :string
  end
end
