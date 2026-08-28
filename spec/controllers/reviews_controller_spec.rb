require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  before(:each) do
    @user = User.create!(email_address: "reviews_controller_spec@example.com", password: "password123")
    sign_in_as(@user)
    @movie = Movie.create!(title: "Titanic", overview: "A ship sinks.")
    @list = List.create!(name: "Drama", user: @user)
    @bookmark = Bookmark.create!(list: @list, movie: @movie)
  end

  describe "POST create" do
    it "creates a review for the bookmark" do
      expect {
        post :create, params: { bookmark_id: @bookmark.id, review: { content: "Great!", rating: 5 } }
      }.to change(Review, :count).by(1)
      expect(response).to redirect_to(@list)
    end
  end

  describe "PATCH update" do
    it "updates the reviewer's own review" do
      review = Review.create!(bookmark: @bookmark, content: "Good", rating: 3)
      patch :update, params: { bookmark_id: @bookmark.id, id: review.id, review: { content: "Even better", rating: 5 } }

      expect(review.reload.content).to eq("Even better")
      expect(review.rating).to eq(5)
    end

    it "does not update another user's review" do
      other_user = User.create!(email_address: "other_reviews_controller_spec@example.com", password: "password123")
      other_list = List.create!(name: "Comedy", user: other_user)
      other_bookmark = Bookmark.create!(list: other_list, movie: @movie)
      other_review = Review.create!(bookmark: other_bookmark, content: "Not yours", rating: 1)

      expect {
        patch :update, params: { bookmark_id: other_bookmark.id, id: other_review.id, review: { content: "Hijacked" } }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE destroy" do
    it "deletes the reviewer's own review" do
      review = Review.create!(bookmark: @bookmark, content: "Good", rating: 3)
      expect {
        delete :destroy, params: { bookmark_id: @bookmark.id, id: review.id }
      }.to change(Review, :count).by(-1)
    end
  end
end
