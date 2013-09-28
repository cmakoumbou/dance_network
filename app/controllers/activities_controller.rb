class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    #@comment_activities = PublicActivity::Activity.order("created_at desc").where(recipient_id: current_user.textpost_ids, recipient_type: "Textpost")
    #@relationship_activities = PublicActivity::Activity.order("created_at desc").where(recipient_id: current_user, recipient_type: "User")
    @activities = PublicActivity::Activity.order("created_at desc").where(recipient_id: current_user.id, recipient_type: "User").where.not(owner_id: current_user.id)
  end
end