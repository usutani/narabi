class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :body
      t.integer :order

      t.timestamps
    end
  end
end
