class AddMarkToDiagram < ActiveRecord::Migration
  def change
    add_column :diagrams, :mark, :string
  end
end
