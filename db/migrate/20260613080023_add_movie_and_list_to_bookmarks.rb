class AddMovieAndListToBookmarks < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookmarks, :movie, null: false, foreign_key: true
    add_reference :bookmarks, :list, null: false, foreign_key: true
  end
end
