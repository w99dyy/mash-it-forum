class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.integer :views_count
      t.boolean :pinned
      t.boolean :locked

      t.timestamps
    end
  end
end
