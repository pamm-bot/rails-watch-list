require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  before(:each) do
    @user = User.create!(email_address: "movies_controller_spec@example.com", password: "password123")
    sign_in_as(@user)
    @list = List.create!(name: "Drama", user: @user)
  end

  let(:ordinary_result) do
    { "title" => "Titanic", "poster_path" => "/titanic.jpg", "genre_ids" => [ 18 ], "adult" => false, "vote_average" => 7.9 }
  end

  let(:mature_result) do
    { "title" => "Scary Movie", "poster_path" => "/scary.jpg", "genre_ids" => [ 27 ], "adult" => false, "vote_average" => 6.0 }
  end

  describe "GET index" do
    it "searches by title when a query is given" do
      allow(TmdbClient).to receive(:search).with("Titanic", language: "en-US").and_return([ ordinary_result ])
      allow(TmdbClient).to receive(:discover)

      get :index, params: { list_id: @list.id, query: "Titanic" }

      expect(TmdbClient).to have_received(:search).with("Titanic", language: "en-US")
      expect(TmdbClient).not_to have_received(:discover)
      expect(assigns(:results)).to eq([ ordinary_result ])
    end

    it "discovers movies when no query is given" do
      allow(TmdbClient).to receive(:discover).and_return([ ordinary_result ])

      get :index, params: { list_id: @list.id }

      expect(TmdbClient).to have_received(:discover)
      expect(assigns(:results)).to eq([ ordinary_result ])
    end

    it "excludes posterless results" do
      posterless = ordinary_result.merge("poster_path" => nil)
      allow(TmdbClient).to receive(:discover).and_return([ ordinary_result, posterless ])

      get :index, params: { list_id: @list.id }

      expect(assigns(:results)).to eq([ ordinary_result ])
    end

    it "filters out mature results for a kids-mode list" do
      @list.update!(kids_mode: true)
      allow(TmdbClient).to receive(:discover).and_return([ ordinary_result, mature_result ])

      get :index, params: { list_id: @list.id }

      expect(assigns(:results)).to eq([ ordinary_result ])
    end

    it "narrows results by minimum rating" do
      allow(TmdbClient).to receive(:discover).and_return([ ordinary_result, mature_result ])

      get :index, params: { list_id: @list.id, min_rating: "7.0" }

      expect(assigns(:results)).to eq([ ordinary_result ])
    end
  end

  describe "POST create" do
    let(:movie_attributes) do
      { list_id: @list.id, title: "Titanic", overview: "A ship sinks.", poster_path: "/titanic.jpg", vote_average: "7.9" }
    end

    it "creates a movie and bookmarks it to the list" do
      expect {
        post :create, params: movie_attributes
      }.to change(Movie, :count).by(1).and change(Bookmark, :count).by(1)

      expect(response).to redirect_to(@list)
    end

    it "reuses an existing movie with the same title instead of duplicating it" do
      existing = Movie.create!(title: "Titanic", overview: "A ship sinks.")

      expect {
        post :create, params: movie_attributes
      }.to change(Bookmark, :count).by(1).and change(Movie, :count).by(0)

      expect(Bookmark.last.movie).to eq(existing)
    end
  end
end
