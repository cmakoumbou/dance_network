require 'spec_helper'

describe Textpost do

  let(:user) { FactoryGirl.create(:user) }
  before { @textpost = user.textposts.build(content: "Lorem ipsum") }

  subject { @textpost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }

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
end