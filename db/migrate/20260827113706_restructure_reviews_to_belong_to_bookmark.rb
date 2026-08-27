class RestructureReviewsToBelongToBookmark < ActiveRecord::Migration[8.1]
  def up
    Review.delete_all
    remove_reference :reviews, :list, foreign_key: true
    add_reference :reviews, :bookmark, null: false, foreign_key: true
  end

  def down
    remove_reference :reviews, :bookmark, foreign_key: true
    add_reference :reviews, :list, null: false, foreign_key: true
  end
end
