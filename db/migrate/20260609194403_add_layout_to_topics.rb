class AddLayoutToTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :layout, :string
  end
end
