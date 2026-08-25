class Movie < ApplicationRecord
  has_many :bookmarks
  has_many :lists, through: :bookmarks
  belongs_to :category, optional: true

  validates :title, presence: true, uniqueness: true
  validates :overview, presence: true
end
