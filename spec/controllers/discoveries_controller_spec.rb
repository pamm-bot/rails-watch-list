require 'rails_helper'

RSpec.describe DiscoveriesController, type: :controller do
  before(:each) do
    @user = User.create!(email_address: "discoveries_controller_spec@example.com", password: "password123")
    sign_in_as(@user)
    @list = List.create!(name: "Watch soon", user: @user)
  end

  def tmdb_result(id:, title:, genre_ids: [ 18 ], vote_average: 7.5, adult: false)
    {
      "id" => id, "title" => title, "poster_path" => "/#{id}.jpg",
      "overview" => "About #{title}.", "genre_ids" => genre_ids,
      "vote_average" => vote_average, "adult" => adult
    }
  end

  let(:card_params) do
    {
      list_id: @list.id, tmdb_id: "603", title: "The Matrix",
      overview: "A hacker learns the truth.", poster_path: "/matrix.jpg",
      vote_average: "8.2", genre_id: "878"
    }
  end

  describe "GET show" do
    it "assigns the first usable candidate" do
      allow(TmdbClient).to receive(:discover).and_return([ tmdb_result(id: 1, title: "Heat") ])

      get :show, params: { list_id: @list.id }

      expect(assigns(:movie)["title"]).to eq("Heat")
    end

    it "skips a candidate already in the list" do
      movie = Movie.create!(title: "Heat", overview: "Crime saga.")
      Bookmark.create!(list: @list, movie: movie)
      allow(TmdbClient).to receive(:discover).and_return([
        tmdb_result(id: 1, title: "Heat"), tmdb_result(id: 2, title: "Collateral")
      ])

      get :show, params: { list_id: @list.id }

      expect(assigns(:movie)["title"]).to eq("Collateral")
    end

    it "excludes a card already recorded as seen" do
      allow(Rails.cache).to receive(:read).and_return([ "1" ])
      allow(TmdbClient).to receive(:discover).and_return([
        tmdb_result(id: 1, title: "Heat"), tmdb_result(id: 2, title: "Collateral")
      ])

      get :show, params: { list_id: @list.id }

      expect(assigns(:movie)["id"]).to eq(2)
    end

    it "filters mature candidates for a kids-mode list" do
      @list.update!(kids_mode: true)
      allow(TmdbClient).to receive(:discover).and_return([
        tmdb_result(id: 1, title: "Saw", genre_ids: [ 27 ]),
        tmdb_result(id: 2, title: "Paddington", genre_ids: [ 10751 ])
      ])

      get :show, params: { list_id: @list.id }

      expect(assigns(:movie)["title"]).to eq("Paddington")
    end

    it "biases the deck toward the genre the list already leans on" do
      drama = Category.find_or_create_by!(name: "Drama")
      Bookmark.create!(list: @list, movie: Movie.create!(title: "Nomadland", overview: "Road.", category: drama))
      allow(TmdbClient).to receive(:discover).and_return([ tmdb_result(id: 9, title: "Marriage Story") ])

      get :show, params: { list_id: @list.id }

      expect(TmdbClient).to have_received(:discover).with(hash_including(genre_id: "18")).at_least(:once)
    end

    it "assigns nil when nothing survives filtering" do
      allow(TmdbClient).to receive(:discover).and_return([])

      get :show, params: { list_id: @list.id }

      expect(assigns(:movie)).to be_nil
    end

    it "404s for another user's list" do
      other = List.create!(name: "Private", user: User.create!(email_address: "other_disc@example.com", password: "password123"))

      expect {
        get :show, params: { list_id: other.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST answer" do
    before { allow(TmdbClient).to receive(:discover).and_return([]) }

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
