class MoviesController < ApplicationController
  def index
    @query = params[:query]
    @list = List.find(params[:list_id])
    @results = TmdbClient.search(@query)
    if @list.kids_mode?
      @results = @results.reject { |r| TmdbClient.mature?(r["genre_ids"], adult: r["adult"]) }
    end
    @titles_in_list = @list.movies.pluck(:title)
  end

  def create
    @list = List.find(params[:list_id])
    @movie = Movie.find_or_initialize_by(title: params[:title])
    @movie.overview = params[:overview].presence || "No overview available."
    @movie.poster_url = TmdbClient.poster_url(params[:poster_path])
    @movie.rating = params[:vote_average].to_f.round

    if (genre_name = TmdbClient.genre_name(params[:genre_id]))
      @movie.category = Category.find_or_create_by(name: genre_name)
    end

    if @movie.save
      Bookmark.find_or_create_by(list: @list, movie: @movie) do |bookmark|
        bookmark.watched = params[:watched] == "1"
      end
      redirect_to @list, notice: "#{@movie.title} added to #{@list.name}."
    else
      redirect_to movies_path(list_id: @list.id), alert: @movie.errors.full_messages.to_sentence
    end
  end

end
