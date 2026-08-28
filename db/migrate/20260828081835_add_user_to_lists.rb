class AddUserToLists < ActiveRecord::Migration[8.1]
  def up
    add_reference :lists, :user, foreign_key: true
    List.reset_column_information

    # Existing lists predate accounts and have no owner to backfill to;
    # they're all just test data from building this app.
    List.where(user_id: nil).destroy_all

    change_column_null :lists, :user_id, false
  end

  def down
    remove_reference :lists, :user, foreign_key: true
  end
end
