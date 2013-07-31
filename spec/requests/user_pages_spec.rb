require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let(:wrong_user) { FactoryGirl.create(:user) }
    let!(:t1) { FactoryGirl.create(:textpost, user: user, content: "Foo") }
    let!(:t2) { FactoryGirl.create(:textpost, user: user, content: "Bar") }

    before { visit user_root_path(user) }

    it { should have_title(user.first_name + " " + user.last_name) }
    it { should have_selector('h1', text: user.first_name + " " + user.last_name) }
    it { should have_css("img[src*='avatar']") }

    describe "textposts" do
      it { should have_content(t1.content) }
      it { should have_content(t2.content) }
      it { should have_content(user.textposts.count) }
    end

    describe "visiting another users profile" do
      before { visit user_root_path(wrong_user) }

      it { should_not have_link('delete') }
    end
  end

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_index_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.first_name + " " + user.last_name)
        end
      end
    end
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
        it { should have_content("First name can't be blank") }
        it { should have_content("Last name can't be blank") }
        it { should have_content("Username can't be blank") }
  			it { should have_content("Email can't be blank") }
  			it { should have_content("Password can't be blank") }
  		end
  	end

  	describe "with valid information" do
  		before do
        fill_in "First name", with: "Example"
        fill_in "Last name", with: "User"
        fill_in "Username", with: "superbboy"
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

        it { should have_title(user.first_name + " " + user.last_name) }
        it { should have_link('Sign out') }
  			it { should have_content("Welcome! You have signed up successfully.") }
  		end
  	end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_registration_path
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit your profile") }
    end

    describe "with invalid information" do
      let(:invalid_first_name) { "c" * 60 }
      before do
        fill_in "First name", with: invalid_first_name
        click_button "Save changes"
      end

      it { should have_content('error') }
      it { should have_content("First name is too long") }
    end

    describe "with valid information" do
      let(:new_first_name) { "John" }
      let(:new_last_name) { "Doe" }
      let(:new_email) { "new@example.com" }
      let(:new_username) { "bboy_example" }
      let(:new_sex) { "Male" }
      let(:new_bio) { "Hi, I am the Bboy King" }
      let(:new_city) { "Sheffield" }
      let(:new_avatar) { File.join(Rails.root, 'spec', 'support', 'images', 'mypicture.png') }
      before do
        fill_in "First name", with: new_first_name
        fill_in "Last name", with: new_last_name
        fill_in "Email", with: new_email
        fill_in "Username", with: new_username
        select('6', :from => 'user_date_of_birth_3i')
        select('February', :from => 'user_date_of_birth_2i')
        select('1991', :from => 'user_date_of_birth_1i')
        select(new_sex, :from => 'Sex')
        fill_in "Bio", with: new_bio
        select('Sheffield', :from => 'City')
        attach_file('Avatar', new_avatar)
        click_button "Save changes"
      end

      it { should have_title(new_first_name + " " + new_last_name) }
      it { should have_selector('p', text: new_bio) }
      it { should have_selector('p', text: new_city) }
      it { should have_css("img[src*='mypicture']") }
      it { should have_content("You updated your account successfully.") }
      it { should have_link('Sign out', href: destroy_user_session_path) }
      specify { expect(user.reload.first_name).to eq new_first_name }
      specify { expect(user.reload.last_name).to eq new_last_name }
      specify { expect(user.reload.email).to eq new_email }
      specify { expect(user.reload.username).to eq new_username }
      specify { expect(user.reload.date_of_birth).to eq Date.new(1991, 02, 06) }
      specify { expect(user.reload.sex).to eq new_sex }
      specify { expect(user.reload.bio).to eq new_bio }
      specify { expect(user.reload.city).to eq new_city }
      specify { expect(user.reload.avatar_file_name).to eq 'mypicture.png' }
    end

    describe "cancel my account" do
      it { should have_content("Cancel my account") }
      it { should have_button('Cancel my account') }

      it "should delete user" do
        expect do
          click_button "Cancel my account"
        end.to change(User, :count).by(-1)
      end
    end
  end
end