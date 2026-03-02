class RemoveMashitAvatarFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :mashit_avatar_data, :string
    remove_column :users, :mashit_avatar_url, :string
  end
end
