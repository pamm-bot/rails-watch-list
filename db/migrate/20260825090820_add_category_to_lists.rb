class AddCategoryToLists < ActiveRecord::Migration[8.1]
  def change
    add_reference :lists, :category, null: true, foreign_key: true
  end
end
