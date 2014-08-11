require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Dance Network' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:textpost) { FactoryGirl.create(:textpost, user: user, content: "Lorem ipsum") }
      before do
        #FactoryGirl.create(:textpost, user: user, content: "Dolor sit amet")
        FactoryGirl.create(:comment, textpost: textpost, user: user, content: "Hello, this is my comment")
        sign_in user
        visit root_path
      end

      it { should have_content('1 textpost') }
      it { should have_content('Hello, this is my comment') }

      describe "with multiple textposts" do
        before do
          29.times { FactoryGirl.create(:textpost, user: user, content: "Dolor sit amet") }
          visit root_path
        end

        it { should have_content('30 textposts') }

        # it "should render the user's feed" do
        #   user.feed.each do |item|
        #     expect(page).to have_selector("li##{item.id}", text: item.content)
        #   end
        # end

        # it "should paginate the feed" do
        #   5.times { FactoryGirl.create(:textpost, user: user, content: "Consectetur adipiscing elit") }
        #   visit root_path
        #   expect(page).to have_selector('div.pagination')
        # end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "Home"
    expect(page).to have_title(full_title(''))
  end
end