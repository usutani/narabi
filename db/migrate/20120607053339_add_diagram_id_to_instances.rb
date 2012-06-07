class AddDiagramIdToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :diagram_id, :integer
  end
end
