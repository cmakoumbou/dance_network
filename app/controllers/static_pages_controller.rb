class StaticPagesController < ApplicationController
  def home
  	if user_signed_in?
  		@textpost = current_user.textposts.build
  		@feed_items = current_user.feed.page(params[:page])
      @comment = Comment.new
  	end
  end
end
