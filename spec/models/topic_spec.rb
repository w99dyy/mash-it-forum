require 'rails_helper'

RSpec.describe Topic, type: :model do
  let(:admin_user) { create(:user, admin: true) }
  let(:user) { create(:user, admin: false) }
  
  describe "Authorization" do
    it "user is not admin" do
      topic = build(:topic, user: user)
      expect(topic).not_to be_valid
      expect(topic.errors[:user]).to include("must be admin!")
    end

    it "user is admin" do
      topic = build(:topic, user: admin_user)
      expect(topic).to be_valid
    end
  end

  describe "Validations" do
    it "topic should contain title" do
      topic = build(:topic, user: admin_user, title: nil)
      expect(topic).not_to be_valid
    end
    
    it "title should've more than 5 characters" do
      topic = build(:topic, user: admin_user, title: "test")
      expect(topic).not_to be_valid
    end

    it "title is valid" do
      topic = build(:topic, user: admin_user, title: "Hi mom!")
      expect(topic).to be_valid
    end
  end
end
