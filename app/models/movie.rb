class Movie < ApplicationRecord
  has_many :bookmarks
  has_many :lists, through: :bookmarks
  belongs_to :category, optional: true

  validates :title, presence: true, uniqueness: true
  validates :overview, presence: true

  # Build (or reuse, by title) a Movie from a TMDb result payload, shared by
  # the search "Add" flow and the discovery deck. Saves and returns it; the
  # caller checks `persisted?`.
  def self.upsert_from_tmdb(title:, overview:, poster_path:, vote_average:, genre_id:)
    movie = find_or_initialize_by(title: title)
    movie.overview = overview.presence || I18n.t("movies.no_overview")
    movie.poster_url = TmdbClient.poster_url(poster_path)
    movie.rating = vote_average.to_f.round

    if (genre_name = TmdbClient.genre_name(genre_id))
      movie.category = Category.find_or_create_by(name: genre_name)
    end

    movie.save
    movie
  end
end
