class AddCategoryToMovies < ActiveRecord::Migration[8.1]
  def change
    add_reference :movies, :category, null: true, foreign_key: true
  end
end
