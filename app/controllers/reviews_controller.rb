class ReviewsController < ApplicationController
  def create
    @bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    @review = @bookmark.reviews.new(review_params)

    if @review.save
      respond_with_updated_card
    else
      redirect_to @bookmark.list, alert: @review.errors.full_messages.to_sentence
    end
  end

  def update
    @review = Current.user.reviews.find(params[:id])
    @bookmark = @review.bookmark

    if @review.update(review_params)
      respond_with_updated_card
    else
      redirect_to @bookmark.list, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review = Current.user.reviews.find(params[:id])
    @bookmark = @review.bookmark
    @review.destroy
    respond_with_updated_card
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end

  # Swap just the movie's card in place so the list page keeps its scroll
  # position instead of reloading and jumping to the top.
  def respond_with_updated_card
    @bookmark.reload

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@bookmark),
          partial: "bookmarks/bookmark",
          locals: { bookmark: @bookmark }
        )
      end
      format.html { redirect_to @bookmark.list }
    end
  end
end
