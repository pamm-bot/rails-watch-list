require 'rails_helper'

RSpec.describe DiscoveriesController, type: :controller do
  before(:each) do
    @user = User.create!(email_address: "discoveries_controller_spec@example.com", password: "password123")
    sign_in_as(@user)
    @list = List.create!(name: "Watch soon", user: @user)
    allow(TmdbClient).to receive(:discover).and_return([])
  end

  let(:card_params) do
    {
      list_id: @list.id, tmdb_id: "603", title: "The Matrix",
      overview: "A hacker learns the truth.", poster_path: "/matrix.jpg",
      vote_average: "8.2", genre_id: "878"
    }
  end

  describe "POST answer" do
    it "adds a watched movie with a 5-star review for seen + liked" do
      expect {
        post :answer, params: card_params.merge(seen: "1", verdict: "liked")
      }.to change(Movie, :count).by(1).and change(Bookmark, :count).by(1).and change(Review, :count).by(1)

      bookmark = Bookmark.last
      expect(bookmark.watched).to be(true)
      expect(bookmark.reviews.first.rating).to eq(5)
    end

    it "adds a watched movie with a 2-star review for seen + disliked" do
      post :answer, params: card_params.merge(seen: "1", verdict: "disliked")

      expect(Bookmark.last.watched).to be(true)
      expect(Review.last.rating).to eq(2)
    end

    it "adds an unwatched movie and no review for not seen + want" do
      expect {
        post :answer, params: card_params.merge(seen: "0", verdict: "want")
      }.to change(Movie, :count).by(1).and change(Bookmark, :count).by(1).and change(Review, :count).by(0)

      expect(Bookmark.last.watched).to be(false)
    end

    it "saves nothing for not seen + skip" do
      expect {
        post :answer, params: card_params.merge(seen: "0", verdict: "skip")
      }.to change(Movie, :count).by(0).and change(Bookmark, :count).by(0)
    end

    it "records the answered card so it will not come back" do
      allow(Rails.cache).to receive(:write)

      post :answer, params: card_params.merge(tmdb_id: "1", seen: "0", verdict: "skip")

      expect(Rails.cache).to have_received(:write).with(
        a_string_including("discover:seen"), array_including("1"), hash_including(:expires_in)
      )
    end

    it "reuses an existing movie by title" do
      Movie.create!(title: "The Matrix", overview: "Old copy.")

      expect {
        post :answer, params: card_params.merge(seen: "1", verdict: "liked")
      }.to change(Bookmark, :count).by(1).and change(Movie, :count).by(0)
    end

    it "responds with a turbo stream" do
      post :answer, params: card_params.merge(seen: "0", verdict: "skip")

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
    end
  end
end
