class AddWatchedToBookmarks < ActiveRecord::Migration[8.1]
  def change
    add_column :bookmarks, :watched, :boolean, default: false, null: false
  end
end
