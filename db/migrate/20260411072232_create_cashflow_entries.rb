class CreateCashflowEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :cashflow_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :entry_type
      t.decimal :amount, precision: 10, scale: 2
      t.string :description
      t.date :occurred_on

      t.timestamps
    end
  end
end
