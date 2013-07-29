class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
  	@users = User.paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
  	@textposts = @user.textposts.paginate(page: params[:page])
  end
end
