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

require 'spec_helper'

describe User do

  before do
  @user = User.new( email: "user@example.com", password: "foobar", password_confirmation: "foobar", username: "Sample")
  end

	subject { @user }

# == User Details

	it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:username) }
  it { should respond_to(:textposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:comments) }
  
  it { should be_valid }

# == Username

  describe "when username is not present" do
    before { @user.username = "" }
    it { should_not be_valid }
  end

  describe "when username is invalid" do
    it "should be invalid" do
      usernames = %w[@user user..lol user-name* user@user.com]
      usernames.each do |invalid_usernames|
        @user.username = invalid_usernames
        @user.should_not be_valid
      end
    end
  end

  describe "when username is valid" do
    it "should be valid" do
      usernames = %w[Username _User56 usEr_nAme username56_]
      usernames.each do |valid_address|
        @user.username = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when username is already taken" do
    before do
      user_with_same_username = @user.dup
      user_with_same_username.username = @user.username.upcase
      user_with_same_username.save
    end

    it { should_not be_valid }
  end

  describe "when username is too long" do
    before { @user.username = "a" * 26 }
    it { should_not be_valid }
  end

# == Textpost

  describe "textpost associations" do

    before { @user.save }
    let!(:older_textpost) do
      FactoryGirl.create(:textpost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_textpost) do
      FactoryGirl.create(:textpost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right textposts in the right order" do
      expect(@user.textposts.to_a).to eq [newer_textpost, older_textpost]
    end

    it "should destroy associated textposts" do
      textposts = @user.textposts.to_a
      @user.destroy
      expect(textposts).not_to be_empty
      textposts.each do |textpost|
        expect(Textpost.where(id: textpost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:textpost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.textposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_textpost) }
      its(:feed) { should include(older_textpost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.textposts.each do |textpost|
          should include(textpost)
        end
      end
    end
  end

# == Following

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end

    describe "destroyed user" do
      it "should destroy relationships" do
        @user.destroy
        expect(Relationship.where(follower_id: @user.id, followed_id: other_user.id)).to be_empty
      end
    end

    describe "destroyed other_user" do
      it "should destroy relationships" do
        other_user.destroy
        expect(Relationship.where(followed_id: @user.id, followed_id: other_user.id)).to be_empty
      end
    end
  end
end
