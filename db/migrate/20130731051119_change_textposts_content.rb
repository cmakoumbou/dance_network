class ChangeTextpostsContent < ActiveRecord::Migration
  def change
  	change_column :textposts, :content, :text
  end
end
