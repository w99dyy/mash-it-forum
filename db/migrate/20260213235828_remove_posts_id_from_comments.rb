class RemovePostsIdFromComments < ActiveRecord::Migration[8.1]
  def change
    remove_column :comments, :posts_id, :bigint
  end
end
