# == Schema Information
#
# Table name: textposts
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Textpost do

  let(:user) { FactoryGirl.create(:user) }
  before { @textpost = user.textposts.build(content: "Lorem ipsum") }

  subject { @textpost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:comments) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
  	before { @textpost.user_id = nil }
  	it { should_not be_valid }
  end

  describe "with blank content" do
  	before { @textpost.content = " " }
  	it { should_not be_valid }
  end

  describe "with content that is too long" do
  	before { @textpost.content = "a" * 501 }
  	it { should_not be_valid }
  end

  describe "comment associations" do
    before { @textpost.save }
    let!(:older_comment) do
      FactoryGirl.create(:comment, textpost: @textpost, created_at: 1.day.ago)
    end
    let!(:newer_comment) do
      FactoryGirl.create(:comment, textpost: @textpost, created_at: 1.hour.ago)
    end

    it "should destroy associated comments" do
      comments = @textpost.comments.to_a
      @textpost.destroy
      expect(comments).not_to be_empty
      comments.each do |comment|
        expect(Comment.where(id: comment.id)).to be_empty
      end
    end
  end
end
