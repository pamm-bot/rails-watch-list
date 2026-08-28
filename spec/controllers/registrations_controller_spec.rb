require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:valid_attributes) do
    { user: { email_address: "registrations_controller_spec@example.com", password: "password123", password_confirmation: "password123" } }
  end

  describe "POST create" do
    it "creates a new user" do
      expect {
        post :create, params: valid_attributes
      }.to change(User, :count).by(1)
    end

    it "signs the new user in" do
      post :create, params: valid_attributes
      expect(Session.count).to eq(1)
    end

    it "does not create a user with a duplicate email" do
      User.create!(email_address: "registrations_controller_spec@example.com", password: "password123")

      expect {
        post :create, params: valid_attributes
      }.not_to change(User, :count)
      expect(response).to render_template(:new)
    end
  end
end
