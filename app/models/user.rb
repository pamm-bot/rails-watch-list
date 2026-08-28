class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :bookmarks, through: :lists
  has_many :reviews, through: :bookmarks

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end
end
