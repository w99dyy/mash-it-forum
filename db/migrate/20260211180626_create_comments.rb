class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.string :author_name
      t.text :body
      t.references :posts, null: false, foreign_key: true

      t.timestamps
    end
  end
end
