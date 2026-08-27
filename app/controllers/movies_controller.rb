class MoviesController < ApplicationController
  def index
    @query = params[:query]
    @results = TmdbClient.search(@query)
    @list = List.find(params[:list_id]) if params[:list_id].present?
  end

  def create
    @movie = Movie.find_or_initialize_by(title: params[:title])
    @movie.overview = params[:overview].presence || "No overview available."
    @movie.poster_url = TmdbClient.poster_url(params[:poster_path])
    @movie.rating = params[:vote_average].to_f.round

    if (genre_name = TmdbClient.genre_name(params[:genre_id]))
      @movie.category = Category.find_or_create_by(name: genre_name)
    end

    if @movie.save
      if params[:list_id].present?
        list = List.find(params[:list_id])
        Bookmark.find_or_create_by(list: list, movie: @movie) do |bookmark|
          bookmark.watched = params[:watched] == "1"
        end
        redirect_to list, notice: "#{@movie.title} added to #{list.name}."
      else
        redirect_to movies_path, notice: "#{@movie.title} added to your movies."
      end
    else
      redirect_to movies_path, alert: @movie.errors.full_messages.to_sentence
    end
  end

end
