class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :following, :followers]

  def index
  	@users = User.paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
  	@textposts = @user.textposts.paginate(page: params[:page])
    @comment = Comment.new
  end

  def following
  	@title = "Following"
  	@user = User.find(params[:id])
  	@users = @user.followed_users.paginate(page: params[:page])
  	render 'show_follow'
  end

  def followers
  	@title = "Followers"
  	@user = User.find(params[:id])
  	@users = @user.followers.paginate(page: params[:page])
  	render 'show_follow'
  end

  private 
    def user_params
      params.require(:user).permit(:current_password)
    end
end
