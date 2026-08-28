require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let!(:user) do
    User.create!(email_address: "passwords_controller_spec@example.com", password: "password123")
  end

  describe "POST create" do
    it "sends a reset email for a known address" do
      expect {
        post :create, params: { email_address: user.email_address }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(response).to redirect_to(new_session_path)
    end

    it "responds the same way for an unknown address, without sending an email" do
      expect {
        post :create, params: { email_address: "nobody@example.com" }
      }.not_to change(ActionMailer::Base.deliveries, :count)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "PATCH update" do
    it "resets the password with a valid token" do
      token = user.generate_token_for(:password_reset)
      patch :update, params: { token: token, password: "newpassword123", password_confirmation: "newpassword123" }

      expect(response).to redirect_to(new_session_path)
      expect(user.reload.authenticate("newpassword123")).to eq(user)
    end

    it "rejects an invalid token" do
      patch :update, params: { token: "not-a-real-token", password: "newpassword123", password_confirmation: "newpassword123" }
      expect(response).to redirect_to(new_password_path)
    end
  end
end
