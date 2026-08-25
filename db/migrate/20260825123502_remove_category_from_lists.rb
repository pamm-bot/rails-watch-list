class RemoveCategoryFromLists < ActiveRecord::Migration[8.1]
  def change
    remove_reference :lists, :category, null: false, foreign_key: true
  end
end
