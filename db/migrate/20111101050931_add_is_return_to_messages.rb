class AddIsReturnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :is_return, :boolean
  end
end
