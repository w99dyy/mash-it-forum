class ChangeMashitAvatarUrlToJson < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :mashit_avatar_url, :string
    add_column :users, :mashit_avatar_url, :json
  end
end
