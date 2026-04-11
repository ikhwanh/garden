class RenameSeedAtColumnsToOn < ActiveRecord::Migration[8.0]
  def change
    rename_column :seeds, :started_at, :started_on
    rename_column :seeds, :transplanted_at, :transplanted_on
  end
end
