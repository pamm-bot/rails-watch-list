require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) do
    User.create!(email_address: "sessions_controller_spec@example.com", password: "password123")
  end

  describe "POST create" do
    it "starts a session with the correct credentials" do
      post :create, params: { email_address: user.email_address, password: "password123" }
      expect(response).to redirect_to(root_url)
      expect(user.sessions.count).to eq(1)
    end

    it "does not start a session with the wrong password" do
      post :create, params: { email_address: user.email_address, password: "wrongpassword" }
      expect(response).to redirect_to(new_session_path)
      expect(user.sessions.count).to eq(0)
    end
  end

  describe "DELETE destroy" do
    it "ends the current session" do
      sign_in_as(user)
      expect {
        delete :destroy
      }.to change(Session, :count).by(-1)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
