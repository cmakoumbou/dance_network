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

    	describe "like a textpost" do
    		it { should have_link("Like", href: like_textpost_path(textpost)) }

    		it "should increment the likes count" do
    	 		expect {
    	 			click_link "Like"
    	 		}.to change{ textpost.get_likes.size }.by(1)
    		end

    		describe "toggling the link" do
    			before { click_link "Like" }
    			it { should have_link("Unlike", href: unlike_textpost_path(textpost)) }
    		end
    	end

    	describe "unlike a textpost" do
    		before do
    			textpost.liked_by user
    			visit user_root_path(user)
    		end

    		it { should have_link("Unlike", href: unlike_textpost_path(textpost)) }

    		it "should decrement the likes count" do
    			expect {
    				click_link "Unlike"
    			}.to change{ textpost.get_likes.size }.by(-1)
    		end

    		describe "toggling the link" do
    			before { click_link "Unlike" }
    			it { should have_link("Like", href: like_textpost_path(textpost)) }
    		end
    	end
    end

    describe "likers page" do
    	before do
    		textpost.liked_by other_user
    		visit likers_textpost_path(textpost)
    	end

    	it { should have_title(full_title('Likers')) }
    	it { should have_link(other_user.username, href: user_root_path(other_user)) }
    end

    #describe "like/unlike buttons" do
    	#describe "like a textpost" do
    		#before do
    			#textpost.liked_by other_user
    			#visit user_root_path(user)
    		#end

    		#it "should increment the likes count" do
    			#expect { click_link(like_textpost_path(textpost)) }.to change(Textpost, :count).by(1)
    		#end

    		#describe "toggling the button" do
    			#before { click_link(like_textpost_path(textpost)) }
    			#it { should have_link(unlike_textpost_path(textpost)) }
    		#end
    	#end
        #before { visit user_root_path(user) }

        #it { should have_link("like") }
    #end
end
