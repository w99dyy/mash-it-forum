require 'rails_helper'

RSpec.describe "Wallets", type: :request do
  describe "GET /connect" do
    it "returns http success" do
      get "/wallet/connect"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disconnect" do
    it "returns http success" do
      get "/wallet/disconnect"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update_avatar" do
    it "returns http success" do
      get "/wallet/update_avatar"
      expect(response).to have_http_status(:success)
    end
  end

end
