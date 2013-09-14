class Comment < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :user
  belongs_to :textpost
  validates :user_id, presence: true
  validates :textpost_id, presence: true
  validates :content, presence: true, length: { maximum: 500 }
end
