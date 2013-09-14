class RelationshipsController < ApplicationController
	before_action :authenticate_user!

	respond_to :html, :js

	def create
		@user = User.find(params[:relationship][:followed_id])
	    @relationship = current_user.follow!(@user)
	    @relationship.create_activity :create, owner: current_user, recipient: @user
		respond_with(@user, :location => user_root_path(@user))
		#respond_to do |format|
		#	format.html { redirect_to user_root_path(@user) }
		#	format.js
		#end
	end

	def destroy
		@user = Relationship.find(params[:id]).followed
		current_user.unfollow!(@user)
		respond_with(@user, :location => user_root_path(@user))
		#respond_to do |format|
		#	format.html { redirect_to user_root_path(@user) }
		#	format.js
		#end
	end
end