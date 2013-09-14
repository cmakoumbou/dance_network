class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: :destroy

  def create
    @textpost = Textpost.find(params[:textpost_id])
    @comment = @textpost.comments.build(comment_params)
    @comment.user = current_user
  	if @comment.save
      #@comment.create_activity :create, owner: current_user, recipient: @textpost
      @comment.create_activity :create, owner: current_user, recipient: @textpost.user
    end
  	redirect_to :back
  end

  def destroy
    @textpost = Textpost.find(params[:textpost_id])
    @comment.destroy
    redirect_to :back
  end

  private

    def comment_params
      params.require(:comment).permit(:content)
    end

    def correct_user
      @comment = current_user.comments.find_by(id: params[:id])
      redirect_to :back if @comment.nil?
    end
end