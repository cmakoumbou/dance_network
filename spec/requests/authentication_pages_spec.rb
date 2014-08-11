require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit new_user_session_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
    it { should_not have_link('Users') }
    it { should_not have_link('Profile') }
    it { should_not have_link('Settings') }
    it { should_not have_link('Sign out') }
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
  		before { valid_signin user }

      it { should have_link('Users',       href: users_index_path) }
      it { should have_link('Activities', href: activities_index_path) }
      it { should have_link('Inbox', href: messages_path) }
      it { should have_link('New Message', href: new_message_path) }
  		it { should have_link('Profile', href: user_root_path(user)) }
      it { should have_link('Settings', href: edit_user_registration_path) }
  		it { should have_link('Sign out', href: destroy_user_session_path) }
  		it { should_not have_link('Sign in', href: new_user_session_path) }
  		
  		describe "followed by signout" do
  			before { click_link "Sign out" }
  			it { should have_link('Sign in') }
  		end
  	end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_registration_path
          valid_signin user
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            expect(page).to have_title('Settings')
          end

          describe "when signing in again" do
            before do
              click_link "Sign out"
              sign_in user
            end

            # it "should render the default(profile) page" do
            #   expect(page).to have_title(user.username)
            # end
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_registration_path }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_registration_path }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end

        describe "visiting the user index" do
          before { visit users_index_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Textposts controller" do

        describe "submitting to the create action" do
          before { post textposts_path }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end

        describe "submitting to the destroy action" do
          before { delete textpost_path(FactoryGirl.create(:textpost)) }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end
      end

      describe "in the Relationships controller" do

        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end
      end

      describe "in the Comments controller" do

        describe "submitting to the create action" do
          before { post textpost_comments_path(1) }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end

        describe "submitting to the destroy action" do
          before { delete textpost_comment_path(1, FactoryGirl.create(:comment)) }
          specify { expect(response).to redirect_to(new_user_session_path) }
        end
      end
    end
  end
end