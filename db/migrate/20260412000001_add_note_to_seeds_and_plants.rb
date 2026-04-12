class AddNoteToSeedsAndPlants < ActiveRecord::Migration[8.1]
  def change
    add_column :seeds, :note, :text
    add_column :plants, :note, :text
  end
end
