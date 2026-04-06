class AddLockedToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :locked, :boolean, default: false
  end
end
