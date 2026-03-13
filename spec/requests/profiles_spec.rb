require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  describe "GET /show" do
    it "returns http success" do
      user = create(:user)
      sign_in user

      get "/users/:username"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      user = create(:user)
      sign_in user

      get "/users/:username/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "returns http success" do
      user = create(:user)
      sign_in user

      patch "/users/#{user.username}",
      params: { user: { email: "newprofilerspec@test.dev" } }

      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end
end
