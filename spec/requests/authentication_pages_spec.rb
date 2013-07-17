require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit new_user_session_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
  	before { visit new_user_session_path }

  	describe "with invalid information" do
  		before { click_button "Sign in" }

  		it { should have_title('Sign in') }
  		it { should have_content('Invalid email or password.') }

  		describe "after visiting another page" do
  			before { click_link "Home" }
  			it { should_not have_content('Invalid email or password.') }
  		end
  	end

  	describe "with valid information" do
  		let(:user) { FactoryGirl.create(:user) }
  		before do
  			fill_in "Email", with: user.email
  			fill_in "Password", with: user.password
  			click_button "Sign in"
  		end

  		it { should have_title(user.email) }
  		it { should have_link('Profile', href: user_root_path(user)) }
  		it { should have_link('Sign out', href: destroy_user_session_path) }
  		it { should_not have_link('Sign in', href: new_user_session_path) }
  		
  		describe "followed by signout" do
  			before { click_link "Sign out" }
  			it { should have_link('Sign in') }
  		end
  	end
  end
end