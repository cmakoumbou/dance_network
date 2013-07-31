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

require 'spec_helper'

describe User do

  before do
  @user = User.new(first_name: "Example", last_name: "User", email: "user@example.com", 
    password: "foobar", password_confirmation: "foobar", date_of_birth: Date.today.years_ago(22).to_s,
    sex: "Male", city: "Manchester", bio: "Hi, my name is Example User. I love the b-boy culture!", username: "Sample")
  end

	subject { @user }

# == User Details

	it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
	it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:date_of_birth) }
  it { should respond_to(:sex) }
  it { should respond_to(:city) }
  it { should respond_to(:bio) }
  it { should respond_to(:avatar) }
  it { should respond_to(:username) }
  it { should respond_to(:textposts) }
  it { should respond_to(:feed) }
  
  it { should be_valid }

# == First Name

  describe "when first name is not present" do
    before { @user.first_name = "" }
    it { should_not be_valid }
  end

  describe "when first name is too long" do
    before { @user.first_name = "a" * 51 }
    it { should_not be_valid }
  end

# == Last Name

  describe "when last name is not present" do
    before { @user.last_name = "" }
    it { should_not be_valid }
  end

  describe "when last name is too long" do
    before { @user.last_name = "a" * 51 }
    it { should_not be_valid }
  end

# == Date of Birth

  describe "when date of birth is not present" do
    before { @user.date_of_birth = "" }
    it { should be_valid }
  end

  describe "when date of birth is too old (120 years)" do
    before { @user.date_of_birth = Date.yesterday.years_ago(120).to_s }
    it { should_not be_valid }
  end

  describe "when date of birth is not valid" do
    before { @user.date_of_birth = Date.tomorrow.to_s }
    it { should_not be_valid }
  end

# == Sex

  describe "when sex is not present" do
    before { @user.sex = "" }
    it { should be_valid }
  end

  describe "when sex is not an allowed value" do
    before { @user.sex = "Wrong" }
    it { should_not be_valid }
  end

# == City

  describe "when city is not present" do
    before { @user.city = "" }
    it { should be_valid }
  end

  describe "when city is not an allowed value" do
    before { @user.city = "Wrong" }
    it { should_not be_valid }
  end

# == Bio

  describe "when bio is not filled" do
    before { @user.bio = "" }
    it { should be_valid }
  end

  describe "when bio is too long" do
    before { @user.bio = "c" * 151 }
    it { should_not be_valid }
  end

# == Avatar

  it { should have_attached_file(:avatar) }

  it { should validate_attachment_content_type(:avatar).
                allowing('image/png', 'image/x-png', 'image/jpg',
                  'image/jpeg', 'image/pjpeg').
                rejecting('text/plain', 'text/xml') }

  it { should validate_attachment_size(:avatar).less_than(10.megabytes) }

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

      its(:feed) { should include(newer_textpost) }
      its(:feed) { should include(older_textpost) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end
end
