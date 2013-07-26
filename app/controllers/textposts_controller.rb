class TextpostsController < ApplicationController
	before_filter :authenticate_user!
	before_action :correct_user, only: :destroy

	def create
		@textpost = current_user.textposts.build(textpost_params)
		if @textpost.save
			flash[:sucess] = "Textpost created!"
			redirect_to root_url
		else
			@feed_items = []
			render 'static_pages/home'
		end
	end

	def destroy
		@textpost.destroy
		redirect_to root_url
	end

	private

		def textpost_params
			params.require(:textpost).permit(:content)
		end

		def correct_user
			@textpost = current_user.textposts.find_by(id: params[:id])
			redirect_to root_url if @textpost.nil?
		end
end