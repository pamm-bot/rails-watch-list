class MoviesController < ApplicationController
  def index
    @query = params[:query]
    @list = Current.user.lists.find(params[:list_id])
    @categories = Category.all
    @selected_category_id = params[:category_id]
    @min_rating = params[:min_rating]

    genre_id = TmdbClient::GENRES.key(Category.find(@selected_category_id).name) if @selected_category_id.present?

    language = TmdbClient.language_for(I18n.locale)
    @results = if @query.present?
      TmdbClient.search(@query, language: language)
    else
      TmdbClient.discover(genre_id: genre_id, min_rating: @min_rating, language: language)
    end

    @results = @results.select { |r| r["poster_path"].present? }
    @results = @results.reject { |r| TmdbClient.non_latin_title?(r["title"]) }
    if @list.kids_mode?
      @results = @results.reject { |r| TmdbClient.mature?(r["genre_ids"], adult: r["adult"], title: r["title"], vote_average: r["vote_average"]) }
    end
    if @selected_category_id.present?
      @results = @results.select { |r| r["genre_ids"]&.include?(genre_id) }
    end
    if @min_rating.present?
      @results = @results.select { |r| r["vote_average"].to_f >= @min_rating.to_f }
    end

    @titles_in_list = @list.movies.pluck(:title)
  end

  def create
    @list = Current.user.lists.find(params[:list_id])
    @movie = Movie.upsert_from_tmdb(
      title: params[:title],
      overview: params[:overview],
      poster_path: params[:poster_path],
      vote_average: params[:vote_average],
      genre_id: params[:genre_id]
    )

    # Come back to the search results with the same filters, so adding
    # several movies in a row doesn't kick you out of the list you were
    # browsing.
    filters = params.permit(:query, :category_id, :min_rating).to_h.compact_blank
    search_path = movies_path(list_id: @list.id, **filters)

    if @movie.persisted?
      Bookmark.find_or_create_by(list: @list, movie: @movie)
      redirect_to search_path
    else
      redirect_to search_path, alert: @movie.errors.full_messages.to_sentence
    end
  end
end
