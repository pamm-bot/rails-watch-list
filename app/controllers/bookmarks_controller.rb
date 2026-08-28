class BookmarksController < ApplicationController
  def create
    @list = Current.user.lists.find(params[:list_id])
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.list = @list

    if @bookmark.save
      redirect_to @list
    else
      @categories = Category.all
      @to_watch, @watched = @list.bookmarks_by_watched
      render "lists/show", status: :unprocessable_entity
    end
  end

  def update
    @bookmark = Current.user.bookmarks.find(params[:id])
    @bookmark.update(bookmark_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    bookmark = Current.user.bookmarks.find(params[:id])
    bookmark.destroy
    redirect_to bookmark.list
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:comment, :movie_id, :watched)
  end
end
