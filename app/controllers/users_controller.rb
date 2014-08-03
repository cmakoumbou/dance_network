class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :following, :followers]

  def index
  	@users = User.user_search(params[:query]).page(params[:page])
  end

  def show
  	@user = User.find(params[:id])
  	@textposts = @user.textposts.page(params[:page])
    @comment = Comment.new
  end

  def following
  	@title = "Following"
  	@user = User.find(params[:id])
  	@users = @user.followed_users.page(params[:page])
  	render 'show_follow'
  end

  def followers
  	@title = "Followers"
  	@user = User.find(params[:id])
  	@users = @user.followers.page(params[:page])
  	render 'show_follow'
  end

  private 
    def user_params
      params.require(:user).permit(:current_password)
    end
end
