require 'rails_helper'

RSpec.describe "Comments", type: :request do
  describe "POST /topics/:topic_id/posts/:post_id/comments" do
    it "returns http success" do

      user = create(:user)
      topic = create(:topic, user: user)
      post_record = create(:post, topic: topic, user: user)

      sign_in user

      post "/topics/#{topic.id}/posts/#{post_record.id}/comments",
       params: { comment: { body: "Hello!" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:success)
    end
  end
end
