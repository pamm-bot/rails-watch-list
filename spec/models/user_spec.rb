require 'rails_helper'

RSpec.describe "User", type: :model do
  let(:valid_attributes) do
    { email_address: "user_spec@example.com", password: "password123" }
  end

  it "is valid with an email and a password" do
    user = User.new(valid_attributes)
    expect(user).to be_valid
  end

  it "requires an email address" do
    user = User.new(valid_attributes.merge(email_address: nil))
    expect(user).not_to be_valid
  end

  it "requires a unique email address" do
    User.create!(valid_attributes)
    user = User.new(valid_attributes)
    expect(user).not_to be_valid
  end

  it "treats email addresses as case-insensitive" do
    User.create!(valid_attributes)
    user = User.new(valid_attributes.merge(email_address: valid_attributes[:email_address].upcase))
    expect(user).not_to be_valid
  end

  it "strips and downcases the email address" do
    user = User.create!(valid_attributes.merge(email_address: "  User_Spec@Example.com  "))
    expect(user.email_address).to eq("user_spec@example.com")
  end

  it "requires a password of at least 8 characters" do
    user = User.new(valid_attributes.merge(password: "short"))
    expect(user).not_to be_valid
  end

  it "authenticates with the correct password" do
    user = User.create!(valid_attributes)
    expect(user.authenticate("password123")).to eq(user)
  end

  it "does not authenticate with the wrong password" do
    user = User.create!(valid_attributes)
    expect(user.authenticate("wrongpassword")).to eq(false)
  end

  describe "password reset tokens" do
    it "finds the user from a freshly generated token" do
      user = User.create!(valid_attributes)
      token = user.generate_token_for(:password_reset)
      expect(User.find_by_password_reset_token!(token)).to eq(user)
    end

    it "invalidates the token once the password changes" do
      user = User.create!(valid_attributes)
      token = user.generate_token_for(:password_reset)
      user.update!(password: "newpassword123")

      expect {
        User.find_by_password_reset_token!(token)
      }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
    end
  end
end
