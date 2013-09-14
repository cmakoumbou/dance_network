require 'spec_helper'

describe "Activity pages" do
  
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let!(:textpost) { FactoryGirl.create(:textpost, user: user, content: "I am the best!") }
  

  before { sign_in other_user }

  describe "index page" do

    before do 
      visit user_root_path(user)
      click_button "Follow"
      first(:field, 'comment_content').set 'Hello'
      first(:button, 'Post comment').click
    end

    before do 
      click_link "Sign out"
      sign_in user
      visit activities_index_path
    end

    it { should have_content("#{other_user.username} is now following you.") }
    it { should have_content("#{other_user.username} added a comment to #{textpost.content}")}
  end
end