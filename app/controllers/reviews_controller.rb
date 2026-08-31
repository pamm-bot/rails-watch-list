class ReviewsController < ApplicationController
  def create
    @bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    @review = Review.new(review_params)
    @review.bookmark = @bookmark

    if @review.save
      redirect_to @bookmark.list
    else
      redirect_to @bookmark.list, alert: @review.errors.full_messages.to_sentence
    end
  end

  def update
    @review = Current.user.reviews.find(params[:id])

    if @review.update(review_params)
      redirect_to @review.bookmark.list, notice: "Review updated."
    else
      redirect_to @review.bookmark.list, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    review = Current.user.reviews.find(params[:id])
    list = review.bookmark.list
    review.destroy
    redirect_to list, notice: "Review deleted."
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
