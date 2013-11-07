# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  content     :text
#  user_id     :integer
#  textpost_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Comment do

  let(:user) { FactoryGirl.create(:user) }
  let(:textpost) { FactoryGirl.create(:textpost, user: user) }
  before do 
  	@comment = textpost.comments.build(content: "Hello World")
  	@comment.user = user
  end

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:textpost_id) }
  it { should respond_to(:user) }
  it { should respond_to(:textpost) }
  its(:user) { should eq user }
  its(:textpost) { should eq textpost }

  it { should be_valid }

  describe "when user_id is not present" do
  	before { @comment.user_id = nil }
  	it { should_not be_valid }
  end

  describe "when textpost_id is not present" do
  	before { @comment.user_id = nil }
  	it { should_not be_valid }
  end

  describe "with blank content" do
  	before { @comment.content = " " }
  	it { should_not be_valid }
  end

  describe "with content that is too long" do
  	before { @comment.content = "a" * 501 }
  	it { should_not be_valid }
  end
end
