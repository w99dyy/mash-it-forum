class AddMashitAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mashit_avatar_data, :json
    add_column :users, :mashit_avatar_url, :string
    add_column :users, :wallet_address, :string
  end
end
