class AddCounterCacheToTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :posts_count, :integer
  end
end
