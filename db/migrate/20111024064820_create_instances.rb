class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
