class MoviesController < ApplicationController
  def index
    @query = params[:query]
    @list = Current.user.lists.find(params[:list_id])
    @categories = Category.all
    @selected_category_id = params[:category_id]
    @min_rating = params[:min_rating]

    genre_id = TmdbClient::GENRES.key(Category.find(@selected_category_id).name) if @selected_category_id.present?

    @results = if @query.present?
      TmdbClient.search(@query)
    else
      TmdbClient.discover(genre_id: genre_id, min_rating: @min_rating)
    end

    @results = @results.select { |r| r["poster_path"].present? }
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
    @movie = Movie.find_or_initialize_by(title: params[:title])
    @movie.overview = params[:overview].presence || "No overview available."
    @movie.poster_url = TmdbClient.poster_url(params[:poster_path])
    @movie.rating = params[:vote_average].to_f.round

    if (genre_name = TmdbClient.genre_name(params[:genre_id]))
      @movie.category = Category.find_or_create_by(name: genre_name)
    end

    if @movie.save
      Bookmark.find_or_create_by(list: @list, movie: @movie)
      redirect_to @list
    else
      redirect_to movies_path(list_id: @list.id), alert: @movie.errors.full_messages.to_sentence
    end
  end
end
