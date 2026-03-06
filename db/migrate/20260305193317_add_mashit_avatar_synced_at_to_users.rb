class AddMashitAvatarSyncedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mashit_avatar_synced_at, :datetime
  end
end
