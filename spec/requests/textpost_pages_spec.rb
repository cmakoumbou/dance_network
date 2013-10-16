require 'spec_helper'

describe "TextpostPages" do
	
	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:other_user) { FactoryGirl.create(:user) }
	let(:textpost) { FactoryGirl.create(:textpost, user: user) }
	before { sign_in user }

	describe "textpost creation" do
		before { visit root_path }

		describe "with invalid information" do

			it "should not create a textpost" do
				expect { click_button "Post" }.not_to change(Textpost, :count)
			end

			describe "error messages" do
				before { click_button "Post" }
				it { should have_content('error') }
			end
		end

		describe "with valid information" do

			before { fill_in 'textpost_content', with: "Lorem ipsum" }
			it "should create a micropost" do
				expect { click_button "Post" }.to change(Textpost, :count).by(1)
			end
		end
	end

	describe "textpost destruction" do
		before { FactoryGirl.create(:textpost, user: user) }

		describe "as correct user" do
			before { visit root_path }

			it "should delete a textpost" do
				expect { click_link "delete" }.to change(Textpost, :count).by(-1)
			end
		end
	end

	describe "comment destruction" do
		before { FactoryGirl.create(:comment, textpost: textpost, user: user) }

		describe "as correct user" do
			before { visit root_path }

		    it "should delete a comment" do
		    	expect { first(:link, 'delete_comment').click }.to change(Comment, :count).by(-1)
		    end
		end
    end

    describe "liker counts" do
    	before do
    		textpost.liked_by other_user
    		visit user_root_path(user)
    	end

    	it { should have_link("1 likes", href: likers_textpost_path(textpost)) }
    end

    describe "likers page" do
    	before do
    		textpost.liked_by other_user
    		visit likers_textpost_path(textpost)
    	end

    	it { should have_title(full_title('Likers')) }
    	it { should have_link(other_user.username, href: user_root_path(other_user)) }
    end
end
