# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  date_of_birth          :date
#  sex                    :string(255)
#  bio                    :text
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  city                   :string(255)
#  username               :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :textposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :comments, dependent: :destroy

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "150x150>" },
                      :default_url => "/images/avatar.png"

  acts_as_messageable :required => :body
  acts_as_voter

  before_save { username.downcase! }

  validates_attachment_size :avatar, :less_than => 10.megabytes
  validates_attachment_content_type :avatar, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png)$/,
                        :message => "file type is not allowed (only jpeg and png images)"

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 25 },
    format: { with: /\A[A-Za-z\d_]+\z/, message: "is not valid. Only letters, digits and underscores are allowed" } 

  def feed
    Textpost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  def self.user_search(query)
    if query
      where('username ILIKE ?', "%#{query}%")
    else
      User.all
    end
  end
end
