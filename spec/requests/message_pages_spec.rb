require 'spec_helper'

describe "Message pages" do
  
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }

  before do
    User.acts_as_messageable :required => :body
    @message = other_user.send_message(user, "Hey friend!")
    @second_message = another_user.send_message(user, "Whats up?")
    sign_in user
  end

  describe "index page" do
    before { visit messages_path }

    it { should have_content(other_user.username) }
    it { should have_content(@message.body) }
    it { should have_content(another_user.username) }
    it { should have_content(@second_message.body) }
  end

  describe "message creation" do
  	before { visit new_message_path }

  	describe "with invalid information" do
  	  before { click_button "Send message" }

  	  it "should not send a message" do
  	    user.sent_messages.count.should == 0
  	  end

  	  it { should have_content('User not found') }
  	end

  	describe "with valid information" do
  	  before do
  	  	fill_in 'message_to', with: other_user.username
  	  	fill_in 'message_body', with: "How are you?"
  	  	click_button "Send message"
  	  end

  	  # it "should send a message" do
  	  #   user.sent_messages.count.should == 1
  	  # end
  	end
  end

  describe "show message" do
    before { visit message_path(@message) }

    # it { should have_content(@message.body) }

    describe "reply to message" do
      before do
        fill_in 'acts_as_messageable_message_body', with: "How are you?"
        click_button "Reply"
      end

      # it "should reply to message" do
      # 	user.sent_messages.count.should == 1
      # end
    end
  end

  describe "destroy message" do
    before do
      visit messages_path
      first(:link, 'Delete').click
    end

    it "should delete a message" do
      user.messages.count.should == 1
    end
  end
end