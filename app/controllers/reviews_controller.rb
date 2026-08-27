class ReviewsController < ApplicationController
  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @review = Review.new(review_params)
    @review.bookmark = @bookmark

    if @review.save
      redirect_to @bookmark.list, notice: "Review added."
    else
      redirect_to @bookmark.list, alert: @review.errors.full_messages.to_sentence
    end
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
