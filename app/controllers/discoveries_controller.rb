class DiscoveriesController < ApplicationController
  include Discoverable

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
end
