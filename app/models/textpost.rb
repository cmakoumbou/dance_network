# == Schema Information
#
# Table name: textposts
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Textpost < ActiveRecord::Base
	belongs_to :user
  has_many :comments, dependent: :destroy
  acts_as_votable
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 500 }
	validates :user_id, presence: true

	# Returns textposts from the users being followed by the given user.
  	def self.from_users_followed_by(user)
    	followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    	where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          	user_id: user.id)
  end
end
