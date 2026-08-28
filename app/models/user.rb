class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :bookmarks, through: :lists

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :password, length: { minimum: 8 }, allow_nil: true
end
