require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_root_path(user) }

    it { should have_content(user.email) }
    it { should have_title(user.email) }
  end

  describe "signup page" do
    before { visit new_user_registration_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do

  	before { visit new_user_registration_path }

  	let(:submit) { "Create my account" }

  	describe "with invalid information" do
  		it "should not create a user" do
  			expect { click_button submit }.not_to change(User, :count)
  		end

  		describe "after submission" do
  			before { click_button submit }

  			it { should have_title('Sign up') }
  			it { should have_content('error') }
  			it { should have_content("Email can't be blank") }
  			it { should have_content("Password can't be blank") }
  		end
  	end

  	describe "with valid information" do
  		before do
  			fill_in "Email", with: "user@example.com"
  			fill_in "Password", with: "foobar"
  			fill_in "Password confirmation", with: "foobar"
  		end

  		it "should create a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

  		describe "after saving the user" do
  			before { click_button submit }
  			let(:user) { User.find_by(email: 'user@example.com') }

  			it { should have_title(user.email) }
  			it { should have_content("Welcome! You have signed up successfully.") }
  		end
  	end
  end
end