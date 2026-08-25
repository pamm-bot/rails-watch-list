require "net/http"
require "json"

class TmdbClient
  BASE_URL = "https://api.themoviedb.org/3"
  IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500"

  def self.search(query)
    return [] if query.blank?

    get("/search/movie", query: query)["results"] || []
  end

  def self.poster_url(poster_path)
    return nil if poster_path.blank?

    "#{IMAGE_BASE_URL}#{poster_path}"
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
