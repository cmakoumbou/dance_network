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
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "150x150>" },
                      :default_url => "/assets/avatars/default_avatar.png"

  before_save { username.downcase! }

  validates :first_name, presence: true, length: { maximum: 50 }
  
  validates :last_name, presence: true, length: { maximum: 50 }

  validates_date :date_of_birth, :between => [120.years.ago, Date.current],
                                  :invalid_date_message => "can't be blank",
                                  :on_or_before_message => "is not valid",
                                  :on_or_after_message => "is too old",
                                  :allow_blank => true

  validates :sex, inclusion: { in: ['Male', 'Female'] }, :allow_blank => true

  validates :bio, length: { maximum: 150 }

  validates :city, inclusion: { in: ["Bath", "Birmingham", "Bradford", "Brighton", "Bristol",
                    "Cambridge", "Canterbury", "Carlisle", "Chester", "Chichester", "Coventry", 
                    "Derby", "Durham", "Ely", "Exeter", "Gloucester", "Hereford", "Hull",
                    "Lancaster", "Leeds", "Leicester", "Lichfield", "Lincoln", "Liverpool",
                    "London", "Manchester","Newcastle", "Norwich", "Nottingham", "Oxford",
                    "Peterborough", "Plymouth", "Portsmouth","Preston", "Ripon", "Salford", 
                    "Salisbury", "Sheffield", "Southampton", "St Albans", "Stoke-on-Trent",
                    "Sunderland", "Truro", "Wakefield", "Wells", "Westminster","Wolverhampton",
                    "Worcester", "York"] }, :allow_blank => true

  validates_attachment_size :avatar, :less_than => 10.megabytes
  validates_attachment_content_type :avatar, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png)$/,
                        :message => "file type is not allowed (only jpeg and png images)"

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 25 },
    format: { with: /\A[A-Za-z\d_]+\z/, message: "is not valid. Only letters, digits and underscores are allowed" } 
end
