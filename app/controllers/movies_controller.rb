class MoviesController < ApplicationController
  def update
    @movie = Movie.find(params[:id])
    @movie.update(movie_params)
    redirect_back fallback_location: root_path
  end

  private

  def movie_params
    params.require(:movie).permit(:category_id)
  end
end
