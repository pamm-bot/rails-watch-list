require "net/http"
require "json"

class TmdbClient
  BASE_URL = "https://api.themoviedb.org/3"
  IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500"

  # TMDb's official movie genre list (id => name), stable and rarely changed.
  # See https://developer.themoviedb.org/reference/genre-movie-list
  GENRES = {
    28 => "Action", 12 => "Adventure", 16 => "Animation", 35 => "Comedy",
    80 => "Crime", 99 => "Documentary", 18 => "Drama", 10751 => "Family",
    14 => "Fantasy", 36 => "History", 27 => "Horror", 10402 => "Music",
    9648 => "Mystery", 10749 => "Romance", 878 => "Science Fiction",
    10770 => "TV Movie", 53 => "Thriller", 10752 => "War", 37 => "Western"
  }.freeze

  def self.search(query)
    return [] if query.blank?

    get("/search/movie", query: query, include_adult: false)["results"] || []
  end

  def self.poster_url(poster_path)
    return nil if poster_path.blank?

    "#{IMAGE_BASE_URL}#{poster_path}"
  end

  def self.genre_name(genre_id)
    GENRES[genre_id.to_i]
  end

  # Genres kept out of kids-mode lists. Action stays allowed on purpose.
  MATURE_GENRE_IDS = [ 27 ].freeze # Horror

  # TMDb's own "adult" flag misses a lot of borderline/explicit titles
  # (e.g. parody or exploitation movies with these words right in the
  # title), so this catches them by keyword as a second line of defense.
  EXPLICIT_KEYWORDS = %w[porn porno pornographic xxx erotic erotica].freeze

  def self.mature?(genre_ids, adult: false, title: nil)
    adult ||
      (genre_ids || []).any? { |id| MATURE_GENRE_IDS.include?(id.to_i) } ||
      explicit_title?(title)
  end

  def self.explicit_title?(title)
    return false if title.blank?

    downcased = title.downcase
    EXPLICIT_KEYWORDS.any? { |word| downcased.include?(word) }
  end

  def self.mature_genre_name?(name)
    MATURE_GENRE_IDS.include?(GENRES.key(name))
  end

  def self.get(path, params)
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params.merge(api_key: api_key))
    JSON.parse(Net::HTTP.get(uri))
  end

  def self.api_key
    Rails.application.credentials.dig(:tmdb, :api_key)
  end
end
