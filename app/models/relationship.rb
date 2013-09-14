class Relationship < ActiveRecord::Base
  include PublicActivity::Common
  #tracked only: :create, owner: ->(controller, model) { controller && controller.current_user }
  
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
