class AddDiagramIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :diagram_id, :integer
  end
end
