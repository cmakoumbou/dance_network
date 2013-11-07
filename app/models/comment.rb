# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  content     :text
#  user_id     :integer
#  textpost_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Comment < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :user
  belongs_to :textpost
  validates :user_id, presence: true
  validates :textpost_id, presence: true
  validates :content, presence: true, length: { maximum: 500 }
end
