class AddKidsModeToLists < ActiveRecord::Migration[8.1]
  def change
    add_column :lists, :kids_mode, :boolean, default: false, null: false
  end
end
