class AddColorAndEmojiToLists < ActiveRecord::Migration[8.1]
  def change
    add_column :lists, :color, :string
    add_column :lists, :emoji, :string
  end
end
