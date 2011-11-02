class AddIsNoteToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :is_note, :boolean
  end
end
