class AddMashitAvatarUrlToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mashit_avatar_url, :string
  end
end
