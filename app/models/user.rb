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
#  about_me               :text
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates_date :date_of_birth, :between => [120.years.ago, Date.current],
                                  :invalid_date_message => "can't be blank",
                                  :on_or_before_message => "is not valid",
                                  :on_or_after_message => "is too old",
                                  :allow_blank => true
  validates :sex, inclusion: { in: %w(Male Female) }, :allow_blank => true                  
  validates :bio, length: { maximum: 150 }
end
