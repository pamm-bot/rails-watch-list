class List < ApplicationRecord
  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, through: :bookmarks

  validates :name, presence: true, uniqueness: true

  def bookmarks_by_watched
    bookmarks.includes(:movie, :reviews).partition { |b| !b.watched? }
  end
end
