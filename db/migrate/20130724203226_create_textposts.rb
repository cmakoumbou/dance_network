class CreateTextposts < ActiveRecord::Migration
  def change
    create_table :textposts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    add_index :textposts, [:user_id, :created_at]
  end
end
