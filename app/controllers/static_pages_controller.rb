class StaticPagesController < ApplicationController
  def home
  	if user_signed_in?
  		@textpost = current_user.textposts.build
  		@feed_items = current_user.feed.paginate(page: params[:page])
      @comment = Comment.new
  	end
  end

  def help
  end

  def about
    #Pusher['test_channel'].trigger('my_event', {message: 'hello world'})
  end

  def contact
  end
end
