class List < ApplicationRecord
  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, through: :bookmarks

  validates :name, presence: true, uniqueness: true

  def bookmarks_by_watched(category_id: nil)
    scope = bookmarks.includes(:movie, :reviews)
    scope = scope.joins(:movie).where(movies: { category_id: category_id }) if category_id.present?
    scope.partition { |b| !b.watched? }
  end
end
