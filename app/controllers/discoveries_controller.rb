class DiscoveriesController < ApplicationController
  MAX_FETCHES = 8
  PAGE_RANGE = (1..15).freeze
  SEEN_TTL = 12.hours
  SEEN_CAP = 300

  def show
    @list = Current.user.lists.find(params[:list_id])
    @movie = next_card(@list)
  end

  def answer
    @list = Current.user.lists.find(params[:list_id])

    apply_verdict(@list, params[:verdict])
    mark_seen(@list, params[:tmdb_id])

    # update (not replace) so the #discover-card wrapper survives for the
    # next answer to target.
    render turbo_stream: turbo_stream.update(
      "discover-card",
      partial: "discoveries/card",
      locals: { movie: next_card(@list), list: @list }
    )
  end

  private

  # "want" -> add to the list as unwatched. "liked" / "disliked" -> add,
  # mark watched, and leave a 5- or 2-star review. "skip" -> nothing.
  def apply_verdict(list, verdict)
    return unless %w[liked disliked want].include?(verdict)

    movie = Movie.upsert_from_tmdb(
      title: params[:title],
      overview: params[:overview],
      poster_path: params[:poster_path],
      vote_average: params[:vote_average],
      genre_id: params[:genre_id]
    )
    return unless movie.persisted?

    bookmark = Bookmark.find_or_create_by(list: list, movie: movie)
    return if verdict == "want"

    bookmark.update(watched: true)
    review = bookmark.reviews.first_or_initialize
    review.rating = verdict == "liked" ? 5 : 2
    review.save
  end

  def next_card(list)
    seen = seen_ids(list)
    titles = list.movies.pluck(:title)
    language = TmdbClient.language_for(I18n.locale)

    # Try the genre-biased deck first, then fall back to plain popularity so
    # the deck doesn't run dry after a handful of answers.
    [ preferred_genre_param(list), nil ].uniq.each do |genre|
      MAX_FETCHES.times do
        results = TmdbClient.discover(genre_id: genre, language: language, page: rand(PAGE_RANGE))
        candidate = results.find { |r| usable_candidate?(r, list, seen, titles) }
        return candidate if candidate
      end
    end

    nil
  end

  def usable_candidate?(result, list, seen, titles)
    result["poster_path"].present? && result["id"].present? &&
      !TmdbClient.non_latin_title?(result["title"]) &&
      seen.exclude?(result["id"].to_s) &&
      titles.exclude?(result["title"]) &&
      !(list.kids_mode? && TmdbClient.mature?(
        result["genre_ids"], adult: result["adult"], title: result["title"], vote_average: result["vote_average"]
      ))
  end

  # Bias the deck toward the one or two genres the list already leans on.
  def preferred_genre_param(list)
    counts = list.movies.where.not(category_id: nil).group(:category_id).count
    return nil if counts.empty?

    top_ids = counts.sort_by { |_, count| -count }.first(2).map(&:first)
    genre_ids = Category.where(id: top_ids).pluck(:name).filter_map { |name| TmdbClient::GENRES.key(name) }
    genre_ids.join("|").presence
  end

  def seen_cache_key(list)
    "discover:seen:#{Current.session&.id}:#{list.id}"
  end

  def seen_ids(list)
    Rails.cache.read(seen_cache_key(list)) || []
  end

  def mark_seen(list, tmdb_id)
    return if tmdb_id.blank?

    ids = (seen_ids(list) + [ tmdb_id.to_s ]).last(SEEN_CAP)
    Rails.cache.write(seen_cache_key(list), ids, expires_in: SEEN_TTL)
  end
end
