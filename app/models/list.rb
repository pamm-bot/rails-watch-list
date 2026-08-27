class List < ApplicationRecord
  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, through: :bookmarks

  validates :name, presence: true, uniqueness: true

  def bookmarks_by_watched(category_id: nil)
    scope = bookmarks.includes(:movie, :reviews)
    scope = scope.joins(:movie).where(movies: { category_id: category_id }) if category_id.present?
    items = scope.to_a
    items = items.select { |b| movie_allowed?(b.movie) } if kids_mode?
    items.partition { |b| !b.watched? }
  end

  def movie_allowed?(movie)
    !kids_mode? || !TmdbClient.mature_genre_name?(movie.category&.name)
  end
end
