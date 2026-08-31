class List < ApplicationRecord
  belongs_to :user
  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, through: :bookmarks

  # The app's accent palette, shared between the default cycling colors
  # on the home page and the picker for customizing a single list.
  ACCENT_COLORS = %w[#f77f00 #e63946 #7209b7 #118ab2 #06d6a0].freeze

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color, inclusion: { in: ACCENT_COLORS }, allow_blank: true
  validates :emoji, length: { maximum: 8 }, allow_blank: true

  def bookmarks_by_watched(category_id: nil)
    scope = bookmarks.includes(:movie, :reviews)
    scope = scope.joins(:movie).where(movies: { category_id: category_id }) if category_id.present?
    items = scope.to_a.select { |b| b.movie.poster_url.present? }
    items = items.select { |b| movie_allowed?(b.movie) } if kids_mode?
    items.partition { |b| !b.watched? }
  end

  def movie_allowed?(movie)
    return true unless kids_mode?

    !TmdbClient.mature_genre_name?(movie.category&.name) &&
      !TmdbClient.explicit_title?(movie.title) &&
      !TmdbClient.low_rated?(movie.rating)
  end
end
