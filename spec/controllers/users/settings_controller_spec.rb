require 'rails_helper'

RSpec.describe Users::SettingsController, type: :controller do

  describe "GET #integrations" do
    it "returns http success" do
      get :integrations
      expect(response).to have_http_status(:success)
    end
  end

end
