class AddCounterCacheToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :integer
  end
end
