class AddUniqueIndexToReviewsBookmarkId < ActiveRecord::Migration[8.1]
  def change
    remove_index :reviews, :bookmark_id
    add_index :reviews, :bookmark_id, unique: true
  end
end
